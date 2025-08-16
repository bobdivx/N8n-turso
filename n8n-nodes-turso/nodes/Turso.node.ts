import {
	IExecuteFunctions,
	INodeExecutionData,
	INodeType,
	INodeTypeDescription,
	NodeApiError,
	NodeOperationError,
} from "n8n-workflow";
import { createClient, Client } from "@libsql/client";

export class Turso implements INodeType {
	description: INodeTypeDescription = {
		displayName: "Turso",
		name: "turso",
		icon: "file:turso.svg",
		group: ["input"],
		version: 1,
		subtitle: "={{$parameter[\"operation\"] + \": \" + $parameter[\"resource\"]}}",
		description: "Interact with a Turso database",
		defaults: {
			name: "Turso",
		},
		inputs: ["main"] as any,
		outputs: ["main"] as any,
		credentials: [
			{
				name: "tursoApi",
				required: true,
			},
		],
		properties: [
			{
				displayName: "Resource",
				name: "resource",
				type: "options",
				noDataExpression: true,
				options: [
					{
						name: "Query",
						value: "query",
					},
					{
						name: "Table",
						value: "table",
					},
					{
						name: "Row",
						value: "row",
					},
				],
				default: "query",
			},
			{
				displayName: "Operation",
				name: "operation",
				type: "options",
				noDataExpression: true,
				displayOptions: {
					show: {
						resource: ["query"],
					},
				},
				options: [
					{
						name: "Execute",
						value: "execute",
						description: "Execute a SQL query",
						action: "Execute a SQL query",
					},
				],
				default: "execute",
			},
			{
				displayName: "Operation",
				name: "operation",
				type: "options",
				noDataExpression: true,
				displayOptions: {
					show: {
						resource: ["table"],
					},
				},
				options: [
					{
						name: "Create",
						value: "create",
						description: "Create a new table",
						action: "Create a table",
					},
					{
						name: "Delete",
						value: "delete",
						description: "Delete a table",
						action: "Delete a table",
					},
				],
				default: "create",
			},
			{
				displayName: "Operation",
				name: "operation",
				type: "options",
				noDataExpression: true,
				displayOptions: {
					show: {
						resource: ["row"],
					},
				},
				options: [
					{
						name: "Insert",
						value: "insert",
						description: "Insert a new row into a table",
						action: "Insert a row",
					},
					{
						name: "Update",
						value: "update",
						description: "Update a row in a table",
						action: "Update a row",
					},
					{
						name: "Delete",
						value: "delete",
						description: "Delete a row from a table",
						action: "Delete a row",
					},
				],
				default: "insert",
			},
			{
				displayName: "SQL Query",
				name: "query",
				type: "string",
				displayOptions: {
					show: {
						resource: ["query"],
						operation: ["execute"],
					},
				},
				default: "",
				placeholder: "SELECT * FROM my_table;",
				description: "The SQL query to execute",
				required: true,
				typeOptions: {
					rows: 5,
				},
			},
			{
				displayName: "Table Name",
				name: "tableName",
				type: "string",
				displayOptions: {
					show: {
						resource: ["table", "row"],
					},
				},
				default: "",
				placeholder: "my_table",
				description: "The name of the table",
				required: true,
			},
			{
				displayName: "Columns",
				name: "columns",
				type: "fixedCollection",
				displayOptions: {
					show: {
						resource: ["table"],
						operation: ["create"],
					},
				},
				default: {},
				placeholder: "Add Column",
				typeOptions: {
					multipleValues: true,
					properties: [
						{
							name: "name",
							displayName: "Name",
							type: "string",
							default: "",
						},
						{
							name: "type",
							displayName: "Type",
							type: "options",
							options: [
								{ name: "TEXT", value: "TEXT" },
								{ name: "INTEGER", value: "INTEGER" },
								{ name: "REAL", value: "REAL" },
								{ name: "BLOB", value: "BLOB" },
								{ name: "NUMERIC", value: "NUMERIC" },
							],
							default: "TEXT",
						},
						{
							name: "primaryKey",
							displayName: "Primary Key",
							type: "boolean",
							default: false,
						},
						{
							name: "notNull",
							displayName: "Not Null",
							type: "boolean",
							default: false,
						},
					],
				},
				description: "The columns of the table",
			},
			{
				displayName: "Data",
				name: "data",
				type: "json",
				displayOptions: {
					show: {
						resource: ["row"],
						operation: ["insert", "update"],
					},
				},
				default: "{}",
				description: "The data to insert or update in JSON format",
				required: true,
			},
			{
				displayName: "Where Clause",
				name: "whereClause",
				type: "string",
				displayOptions: {
					show: {
						resource: ["row"],
						operation: ["update", "delete"],
					},
				},
				default: "",
				placeholder: "id = 1",
				description: "The WHERE clause to identify the row(s) to update or delete",
				required: true,
			},
		],
	};

	async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
		const items = this.getInputData();
		let returnData: INodeExecutionData[] = [];
		const resource = this.getNodeParameter("resource", 0, "") as string;
		const operation = this.getNodeParameter("operation", 0, "") as string;
		const credentials = await this.getCredentials("tursoApi");
		const client: Client = createClient({
			url: credentials.url as string,
			authToken: credentials.authToken as string,
		});
		for (let i = 0; i < items.length; i++) {
			try {
				if (resource === "query") {
					if (operation === "execute") {
						const query = this.getNodeParameter("query", i, "") as string;
						const result = await client.execute(query);
						returnData = this.helpers.returnJsonArray(result.rows as any[]);
					}
				} else if (resource === "table") {
					const tableName = this.getNodeParameter("tableName", i, "") as string;
					if (operation === "create") {
						const columns = (this.getNodeParameter("columns", i, {}) as any).column;
						const columnDefinitions = columns
							.map(
								(col: any) =>
									`${col.name} ${col.type} ${col.primaryKey ? "PRIMARY KEY" : ""} ${
										col.notNull ? "NOT NULL" : ""
									}`,
							)
							.join(", ");
						const query = `CREATE TABLE ${tableName} (${columnDefinitions});`;
						await client.execute(query);
						returnData.push({ json: { success: true, message: `Table ${tableName} created` } });
					} else if (operation === "delete") {
						const query = `DROP TABLE ${tableName};`;
						await client.execute(query);
						returnData.push({ json: { success: true, message: `Table ${tableName} deleted` } });
					}
				} else if (resource === "row") {
					const tableName = this.getNodeParameter("tableName", i, "") as string;
					if (operation === "insert") {
						const data = this.getNodeParameter("data", i, "{}") as string;
						const parsedData = JSON.parse(data);
						const columns = Object.keys(parsedData).join(", ");
						const values = Object.values(parsedData);
						const placeholders = values.map(() => "?").join(", ");
						const query = `INSERT INTO ${tableName} (${columns}) VALUES (${placeholders});`;
						const result = await client.execute({ sql: query, args: values as any[] });
						returnData.push({ json: { success: true, rowsAffected: result.rowsAffected } });
					} else if (operation === "update") {
						const data = this.getNodeParameter("data", i, "{}") as string;
						const whereClause = this.getNodeParameter("whereClause", i, "") as string;
						const parsedData = JSON.parse(data);
						const setClause = Object.keys(parsedData)
							.map((key) => `${key} = ?`)
							.join(", ");
						const values = Object.values(parsedData);
						const query = `UPDATE ${tableName} SET ${setClause} WHERE ${whereClause};`;
						const result = await client.execute({ sql: query, args: values as any[] });
						returnData.push({ json: { success: true, rowsAffected: result.rowsAffected } });
					} else if (operation === "delete") {
						const whereClause = this.getNodeParameter("whereClause", i, "") as string;
						const query = `DELETE FROM ${tableName} WHERE ${whereClause};`;
						const result = await client.execute(query);
						returnData.push({ json: { success: true, rowsAffected: result.rowsAffected } });
					}
				}
			} catch (error) {
				if (this.continueOnFail()) {
					returnData.push({ json: { error: (error as Error).message } });
					continue;
				}
				throw new NodeApiError(this.getNode(), error as any);
			}
		}
		return [this.helpers.returnJsonArray(returnData)];
	}
}
