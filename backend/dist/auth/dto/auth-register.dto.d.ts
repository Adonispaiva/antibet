export declare enum Gender {
    MALE = "male",
    FEMALE = "female",
    OTHER = "other"
}
export declare class AuthRegisterDto {
    email: string;
    password: string;
    name: string;
    birthDate: string;
    gender: Gender;
}
