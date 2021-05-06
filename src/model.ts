export enum TermType {
    Assign,
    Command,
    IfThen,
    ElifChain,
    While,
    Label,
    Goto,
}

export namespace TermType {
    const reverseMap = new Map<string, TermType>();

    Object.keys(TermType).forEach((s: string) => {
        const e = (<any>TermType)[s];
        reverseMap.set(e.toString(), e);
    });

    export function valueOf(str: string) {
        return reverseMap.get(str);
    }
}

export interface ITerm {
    type: string;
}

export interface ICommand extends ITerm {
    name: string;
    args: Array<{ name: string, value: string }>;
    contents?: string;
}

export interface IAssign extends ITerm {
    assignTo: string;
    value: ICommand;
}

export interface IIfThen extends ITerm {
    condition: ICommand;
    thens: Array<ITerm>;
    elses: Array<ITerm>
}

export interface IElifChain extends ITerm {
    thens: Array<{ condition: ICommand, terms: Array<ITerm> }>;
    elses: Array<ITerm>;
}

export interface ISwitch extends ITerm {
    condition: ICommand;
    cases: Array<{ label: string, terms: Array<ITerm> }>;
}

export interface IWhileDo extends ITerm {
    condition: ICommand;
    terms: Array<ITerm>;
}

export interface ILabel extends ITerm {
    label: string;
    target: ITerm;
}

export interface IGoto extends ITerm{
    label: string;
}