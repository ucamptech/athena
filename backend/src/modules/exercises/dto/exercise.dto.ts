import { QuestionSet } from "../../question-set/dto/question-set.dto";
import { Session } from "../../session/dto/session.dto";

export class Exercise {
    exerciseID: string;
    questionSet: QuestionSet[];
    result: 'correct' | 'incorrect';
    timeActivityIsDisplayed: string;
    timeUserIsActive: string;
    exerciseSession: Session;
  }
  