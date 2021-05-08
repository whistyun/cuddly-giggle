{
  var publishedId=0;

  function makeBool(text) { return text; }

  function makeWord(text) { return text; }

  function makeNumber(text) { return text; }

  function makeHereText(text) {
    let lnAry = text.replace(/\r\n/g, "\n").replace(/\r/, "\n").split("\n");

    // 1行目が空なら削除
    if (lnAry[0].length == 0)
        lnAry.splice(0, 1);

    // 最終行が空なら削除
    if (lnAry.length > 1 && lnAry[lnAry.length - 1].length == 0)
        lnAry.splice(lnAry.length - 1, 1);

    // 一行目の前方スペース数を確認する
    let indent = []
    for (let idx = 0; idx < lnAry[0].length; ++idx) {
        let chr = lnAry[0].charAt(idx);
        if (chr == " " || chr == "　" || chr == "\t") {
            indent.push(lnAry[0].charAt(idx));
        }
        else break;
    }

    // 全行を確認し、有効なインデントの数を決定する
    let enableCount = indent.length;
    for (let line of lnAry) {
        if (line.length == 0) continue;

        let atIdx = 0;
        for (atIdx = 0; atIdx < Math.min(enableCount, line.length); ++atIdx)
            if (line.charAt(atIdx) != indent[atIdx])
                break;

        enableCount = Math.min(enableCount, atIdx);
    }

    // 前方のインデントを削除する
    for (let idx = 0; idx < lnAry.length; ++idx) {
        if (lnAry[idx].length == 0) continue;

        lnAry[idx] = lnAry[idx].substring(enableCount);
    }

    return lnAry.join("\r\n");
  }

  function makeText(text){
    let buff = "";
    for (let idx = 0; idx < text.length; ++idx) {
        let ch = text.charAt(idx);
        if (ch == "\\" && idx + 1 < text.length) {
            ch = text.charAt(++idx);
            switch (ch) {
                case "t": buff += "\t"; break;
                case "r": buff += "\r"; break;
                case "n": buff += "\n"; break;
                case "f": buff += "\f"; break;
                default: buff += ch; break;
            }
        }
        else buff += ch;
    }
    return buff;
  }

  function makeCommand(name, args){
    return {
      id: ++publishedId,
      type: "Command",
      name,
      args,
    };
  }

  function makeAssign(assignTo, value){
    return {
      id: ++publishedId,
      type: "Assign",
      assignTo,
      value
    };
  }

  function makeIfThen(condition, thens, elses){
    return elses?
      {
        id: ++publishedId,
        type: "IfThen",
        condition,
        thens,
        elses
      }:
      {
        id: ++publishedId,
        type: "IfThen",
        condition,
        thens
      };
  }

  function makeElifChain(thens, elses){
    return elses?
      {
        id: ++publishedId,
        type: "ElifChain",
        thens,
        elses
      }:
      {
        id: ++publishedId,
        type: "ElifChain",
        thens
      };
  }

  function makeWhile(condition, terms){
    return {
      id: ++publishedId,
      type: "While",
      condition,
      terms
    };
  }

  function makeSwitch(condition, cases){
    return {
      id: ++publishedId,
      type: "Switch",
      condition,
      cases
    };
  }

  function makeGoto(label){
    return {
      id: ++publishedId,
      type: "Goto",
      label
    };
  }

  function makeLabel(label, target){
    return {
      id: ++publishedId,
      type: "Label",
      label,
      target
    };
  }
}

////////////////////////////////////////
// statement
////////////////////////////////////////
Lang
  = ang:CompleteSentence _ {
    return ang;
  }

CompleteSentence
  = b:( _ SentenceAll )+ {
    return b.map(ary=>ary[1]).filter(elm=>!!elm);
  }

SentenceAll = REM / SentenceAssign / SentenceIf / SentenceWhile / SentenceSwitch / SentenceLabel / SentenceGoto / FullCommand

SentenceLabel
  = l:Word _ ":" _ t:(SentenceAssign / SentenceIf / SentenceWhile / SentenceSwitch / FullCommand){
    return makeLabel(l, t);
  }

SentenceGoto
  = ReservedGoto __ l:Word {
    return makeGoto(l);
  }

SentenceAssign
  = t:( Word / Text ) _1 "="  _ v:FullCommand { return makeAssign(t.toString(), v); }
  / t:( Word / Text ) _1 "<-" _ v:FullCommand { return makeAssign(t.toString(), v); }

SentenceSwitch
  = ReservedSwitch __1 cn:CommandLine _1 [\r\n] 
      cs:( __ ReservedCase __1 Text _1 [:\r\n]? _ CompleteSentence? )+
    _ ReservedEnd ( __1 ReservedSwitch )?  _1 [\r\n] {

    return makeSwitch(cn, cs.map(elm=>{ return { label:elm[3], terms: elm[7]? elm[7]: [] } }));
  }

SentenceIf
  = ReservedIf __1 c:ConditionAndCommands 
     elf:( _ ReservedElif __1 ConditionAndCommands )*
     els:( _ ReservedElse __ CompleteSentence? )? _ ReservedEnd ( __1 ReservedIf )? _1 [\r\n] {

    if(elf.length===0){
      // if-else

      return makeIfThen(
        c.condition,
        c.terms,
        els? els[3]: undefined
      );
    }
    else{
      // if-elif-else

      var thenArray = [c];
      Array.prototype.push.apply(thenArray, elf.map(ary=> ary[3]));

      return makeElifChain(
        thenArray,
        els? els[3]: undefined
      );
    }
  }

ConditionAndCommands
  = c:CommandLine _1 ("Then"i)? _1 [\r\n] b:( _ SentenceAll )* {
    var cmds = b.map(ary=>ary[1]).filter(elm=>!!elm);
    return { "condition":c, "terms":cmds };
  }

SentenceWhile
  = ReservedWhile __1  c:CommandLine _1 [\r\n] b:( _ SentenceAll )* _ ReservedEnd ( __1 ReservedWhile )?  _1 [\r\n] {
    var cmds = b.map(ary=>ary[1]).filter(elm=>!!elm);
    return makeWhile(c, cmds);
  }

////////////////////////////////////////
// command
////////////////////////////////////////

FullCommand = c:CommandLine _1 [\r\n;] {return c}

CommandLine = CommandWithArgs / SimpleCommand

SimpleCommand
  = c:( Word / Text ) {
    return makeCommand(c, []);
  }

CommandWithArgs
  = c:( Word / Text ) _1 "(" _ a1:ArgAndValue an:( _ "," _ ArgAndValue )* _ ")" {
    var argArry = [a1];
    Array.prototype.push.apply(argArry, an.map(ary=> ary[3]));
    return makeCommand(c, argArry);
  }

ArgAndValue
  = n:(Word/Text) _ [:=] _  v:DataType {
		return { "name": n.toString(), "value": v };
  }

////////////////////////////////////////
// datatype
////////////////////////////////////////
DataType = Boolean / Word / Text / Number

/** boolean */
Boolean "boolean"
  = ReservedTrue {
    return makeBool("true");
  }
  / ReservedFalse {
    return makeBool("false");
  }

/** variable */
Word "word" =
  "@" (firstLetter secondLetter*)           { return makeWord(text().substring(1)) } /
  ReservedWord secondLetter+                { return makeWord(text())              } /
  !ReservedWord (firstLetter secondLetter*) { return makeWord(text())              }

firstLetter  = [A-Za-z\u3041-\u3096\u30A1-\u30FA\u32D0-\u32FE\u4E00-\u62FF\u6300-\u77FF\u7800-\u8CFF\u8D00-\u9FFF\u30FC]
secondLetter = [A-Za-z0-9_\u3041-\u3096\u30A1-\u30FA\u32D0-\u32FE\u4E00-\u62FF\u6300-\u77FF\u7800-\u8CFF\u8D00-\u9FFF\u30FC\uFF3F]

ReservedWord   = (
  ReservedTrue / ReservedFalse / ReservedIf / ReservedElif / 
  ReservedElse / ReservedWhile / ReservedSwitch / ReservedCase / 
  ReservedEnd / ReservedGoto
) { return null; }

ReservedSwitch = "Switch"i                        { return "Switch";}
ReservedCase   = "Case"i                          { return "Case";  }
ReservedTrue   = "True"i                          { return "True";  }
ReservedFalse  = "False"i                         { return "False"; }
ReservedIf     = "If"i                            { return "If";    }
ReservedElif   = ("Elseif"i / "Elsif"i / "Elif"i) { return "Elif";  }
ReservedElse   = "Else"i                          { return "Else";  }
ReservedWhile  = "While"i                         { return "While"; }
ReservedEnd    = "End"i                           { return "End";   }
ReservedGoto   = "Goto"i                          { return "Goto";  }

/** string */
Text "text"
  = '"""' t:(tritext_linner*) '"""' {
    return makeHereText(t.join(''));
  }
  / '"' t:(dqtext_linner*) '"' {
    return makeText(t.join(''));
	}
  / "'" t:(sqtext_linner*) "'" {
    return makeText(t.join(''));
	}
tritext_linner
  = p:(!'"""' .){return p[1];}
dqtext_linner 
  = '\\"' / p:(!'"' .){return p[1];}
sqtext_linner
  = "\\'" / p:(!"'" .){return p[1];}

/** number */
Number "number"
  = _ [0-9]+("."[0-9]+)*( "E" ("-" / "+")? [0-9]+)? {
    return makeNumber(text());
  }


////////////////////////////////////////
// comments
////////////////////////////////////////
REM "comment"
  = line_comment/block_comment

/** line comment */
line_comment
  = ("//") p:([^\r\n]*) { return null; }

/** block comment */
block_comment
  = p:("/*" multi_liner* "*/") { return null; }
multi_liner
  = p:(!"*/" .) { return null; }

_1 "whitespaceWithoutBreak"
  = [ \t]* { return " "; }

__1 "whitespaceWithoutBreak"
  = [ \t]+ { return " "; }

_ "whitespace"
  = [ \t\n\r]* { return " "; }

__ "whitespace"
  = [ \t\n\r]+ { return " "; }