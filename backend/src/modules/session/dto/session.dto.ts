import { Exercise } from "../../exercises/dto/exercise.dto";

export class Session {
    userID: string;
    loginDate: string;
    accumulatedSessionScore: number;
    exerciseList: Exercise[];
  }
  