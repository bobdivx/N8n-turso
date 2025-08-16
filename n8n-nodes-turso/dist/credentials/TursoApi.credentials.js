"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TursoApi = void 0;
class TursoApi {
    constructor() {
        this.name = "tursoApi";
        this.displayName = "Turso API";
        this.documentationUrl = "https://docs.turso.tech/sdk/ts/reference";
        this.properties = [
            {
                displayName: "Database URL",
                name: "url",
                type: "string",
                default: "",
                placeholder: "libsql://your-database.turso.io",
                description: "The URL of your Turso database",
                required: true,
            },
            {
                displayName: "Auth Token",
                name: "authToken",
                type: "string",
                typeOptions: {
                    password: true,
                },
                default: "",
                description: "The authentication token for your Turso database",
                required: true,
            },
        ];
    }
}
exports.TursoApi = TursoApi;
