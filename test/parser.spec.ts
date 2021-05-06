import { IAssign, ICommand, TermType } from "../src/model";
import { parse } from "../src/peg/parser"

describe('Check syntax', function () {

    it('Command', function () {
        let term = parse("Test(arg1:'val', arg2:false, arg3:3) 'hello, world';")[0];
        let cmd = <ICommand>term;

        expect(cmd.type).toBe(TermType[TermType.Command]);
        expect(cmd.name).toBe("Test");
        expect(cmd.args).toEqual([
            { name: "arg1", value: "val" },
            { name: "arg2", value: "false" },
            { name: "arg3", value: "3" },
        ]);
        expect(cmd.contents).toBe("hello, world");
    });

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

    it('If', function () {

    });
});