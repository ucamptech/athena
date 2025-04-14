import { Choices } from '../../choices/dto/choices.dto'

export class QuestionSet {
    questionID: string;
    question: string;
    options: Choices[];
    correctAnswer: Choices[];
  }
  