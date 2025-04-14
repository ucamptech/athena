import { Session } from "../../session/dto/session.dto";

export class Exercise {
    exerciseID: string;
    assets: string;
    result: 'correct' | 'incorrect';
    timeActivityIsDisplayed: string;
    timeUserIsActive: string;
    exerciseSession: Session;
  }
  