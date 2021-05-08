import { IAssign, ICommand, IElifChain, IIfThen, TermType } from "../src/model";
import { parse } from "../src/peg/parser"
import $ from "jquery"

function getRemote(remote_url: string): string {
    return $.ajax({
        type: "GET",
        url: remote_url,
        async: false
    }).responseText;
}

describe('Check syntax', function () {

    for (let name of ["Command", "Assign1", "Assign2", "IfElse", "IfElif", "Switch", "Mix"]) {
        it(name, function () {
            let input = getRemote("/input/" + name + ".txt");
            let output = getRemote("/output/" + name + ".json");

            let term = parse(input);
            expect(term).toEqual(JSON.parse(output));
        })
    }
    /*
        it('Assign', function () {
            let term = parse("variable = Test(arg1:'val', arg2:false, arg3:3) '\\'hello\\', world';")[0];
            let assign = <IAssign>term;
    
            expect(assign.type).toBe(TermType[TermType.Assign]);
            expect(assign.assignTo).toBe("variable");
    
            let cmd = assign.value;
    
            expect(cmd.type).toBe(TermType[TermType.Command]);
            expect(cmd.name).toBe("Test");
            expect(cmd.args).toEqual([
                { name: "arg1", value: "val" },
                { name: "arg2", value: "false" },
                { name: "arg3", value: "3" },
            ]);
            expect(cmd.contents).toBe("'hello', world");
        });
    
        it('IfThen', function () {
            let term = parse("If condition\ncommand(arg1:123)\nEnd\n")[0];
            let ifthen = <IIfThen>term;
    
            expect(ifthen.type).toBe(TermType[TermType.IfThen]);
    
            expect(ifthen.condition).toEqual({
                type: "Command",
                name: "condition",
                args: []
            });
    
            expect(ifthen.thens).toEqual(
                [<ICommand>{
                    type: "Command",
                    name: "command",
                    args: [
                        { name: "arg1", value: "123" }
                    ]
                }]
            );
    
            expect(ifthen.elses).toBe(undefined);
        });
        it('IfElse', function () {
            let term = parse("If condition\ncommand(arg1:123)\nElse\ncommand2\nEnd\n")[0];
            let ifthen = <IIfThen>term;
    
            expect(ifthen.type).toBe(TermType[TermType.IfThen]);
    
            expect(ifthen.condition).toEqual({
                type: "Command",
                name: "condition",
                args: []
            });
    
            expect(ifthen.thens).toEqual(
                [<ICommand>{
                    type: "Command",
                    name: "command",
                    args: [
                        { name: "arg1", value: "123" }
                    ]
                }]
            );
    
            expect(ifthen.elses).toEqual(
                [<ICommand>{
                    type: "Command",
                    name: "command2",
                    args: []
                }]
            );
        });
        it('IfElif', function () {
            let term = parse("If condition1\ncommand1\nElsif condition2\ncommand2\nEnd\n")[0];
            let ifthen = <IElifChain>term;
    
            expect(ifthen.type).toBe(TermType[TermType.ElifChain]);
            expect(ifthen.thens).toEqual([
                {
                    condition: { type: "Command", name: "condition1", args: [] },
                    terms: [<ICommand>{ type: "Command", name: "command1", args: [] }]
                },
                {
                    condition: { type: "Command", name: "condition2", args: [] },
                    terms: [<ICommand>{ type: "Command", name: "command2", args: [] }]
                }
            ]);
        });
        it('IfElifElse', function () {
            let term = parse("If condition1\ncommand1\nElsif condition2\ncommand2\nElse\ncommand3\nEnd\n")[0];
            let ifthen = <IElifChain>term;
    
            expect(ifthen.type).toBe(TermType[TermType.ElifChain]);
            expect(ifthen.thens).toEqual([
                {
                    condition: { type: "Command", name: "condition1", args: [] },
                    terms: [<ICommand>{ type: "Command", name: "command1", args: [] }]
                },
                {
                    condition: { type: "Command", name: "condition2", args: [] },
                    terms: [<ICommand>{ type: "Command", name: "command2", args: [] }]
                }
            ]);
            expect(ifthen.elses).toEqual(
                [<ICommand>{
                    type: "Command",
                    name: "command3",
                    args: []
                }]
            );
        });
    */
});