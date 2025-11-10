import { User } from '../../user/user.entity';
export declare class Goal {
    id: string;
    title: string;
    description: string;
    isCompleted: boolean;
    dueDate: Date;
    createdAt: Date;
    updatedAt: Date;
    user: User;
    userId: string;
}
