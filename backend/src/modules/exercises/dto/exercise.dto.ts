export class ExerciseList {
    userID: string;
    loginDate: string;
    accumulatedSessionScore: number;
    exercises: Exercise[];
  }
  
export class Exercise {
    exerciseID: string;
    assets: string;
    result: 'correct' | 'incorrect';
    timeActivityIsDisplayed: string;
    timeUserIsActive: string;
  }
  