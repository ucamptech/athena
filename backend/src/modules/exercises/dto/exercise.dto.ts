import { Session } from "../../session/dto/session.dto";

export class Exercise {
    exerciseID: string;
    questionSet: number[];
    result: 'correct' | 'incorrect';
    timeActivityIsDisplayed: string;
    timeUserIsActive: string;
    exerciseSession: Session;
  }
  