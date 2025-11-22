export interface WebhookBody {
    id: string;
    type: string;
    data: {
        object: any;
    };
    created: number;
    [key: string]: any;
}
