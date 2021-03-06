import { IAssign, ICommand, IElifChain, IIfThen, ILabel, ISwitch, IWhileDo } from "../model";

interface ParserOptions {
  startRule?: string;
  tracer: any;
}

export interface Location {
  start: {
    offset: number;
    line: number;
    column: number;
  };
  end: {
    offset: number;
    line: number;
    column: number;
  };
}

export declare class SyntaxError extends Error {
  message: string;
  expected: string | null;
  found: string | null;
  location: Location;
  name: 'SyntaxError';
}

export declare function parse(input: string, options?: ParserOptions): 
    Array<ICommand | IAssign | IIfThen | IElifChain | ISwitch | IWhileDo | ILabel>;