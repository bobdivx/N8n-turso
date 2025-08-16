import {
	ICredentialType,
	INodeProperties,
} from "n8n-workflow";

export class TursoApi implements ICredentialType {
	name = "tursoApi";
	displayName = "Turso API";
	documentationUrl = "https://docs.turso.tech/sdk/ts/reference";
	properties: INodeProperties[] = [
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
