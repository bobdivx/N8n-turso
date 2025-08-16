"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Turso = void 0;
const n8n_workflow_1 = require("n8n-workflow");
const client_1 = require("@libsql/client");
class Turso {
    constructor() {
        this.description = {
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
            inputs: ["main"],
            outputs: ["main"],
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
                        {
                            name: "Add Column",
                            value: "addColumn",
                            description: "Add a column to a table",
                            action: "Add a column to a table",
                        }
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
                    displayName: "Column Name",
                    name: "columnName",
                    type: "string",
                    displayOptions: {
                        show: {
                            resource: ["table"],
                            operation: ["addColumn"],
                        },
                    },
                    default: "",
                    placeholder: "my_column",
                    description: "The name of the new column",
                    required: true,
                },
                {
                    displayName: "Column Type",
                    name: "columnType",
                    type: "options",
                    displayOptions: {
                        show: {
                            resource: ["table"],
                            operation: ["addColumn"],
                        },
                    },
                    options: [
                        { name: "TEXT", value: "TEXT" },
                        { name: "INTEGER", value: "INTEGER" },
                        { name: "REAL", value: "REAL" },
                        { name: "BLOB", value: "BLOB" },
                        { name: "NUMERIC", value: "NUMERIC" },
                    ],
                    default: "TEXT",
                    description: "The type of the new column",
                    required: true,
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
    }
    execute() {
        return __awaiter(this, void 0, void 0, function* () {
            const items = this.getInputData();
            let returnData = [];
            const resource = this.getNodeParameter("resource", 0, "");
            const operation = this.getNodeParameter("operation", 0, "");
            const credentials = yield this.getCredentials("tursoApi");
            const client = (0, client_1.createClient)({
                url: credentials.url,
                authToken: credentials.authToken,
            });
            for (let i = 0; i < items.length; i++) {
                try {
                    if (resource === "query") {
                        if (operation === "execute") {
                            const query = this.getNodeParameter("query", i, "");
                            const result = yield client.execute(query);
                            returnData = this.helpers.returnJsonArray(result.rows);
                        }
                    }
                    else if (resource === "table") {
                        const tableName = this.getNodeParameter("tableName", i, "");
                        if (operation === "create") {
                            const columns = this.getNodeParameter("columns", i, {}).column;
                            const columnDefinitions = columns
                                .map((col) => `${col.name} ${col.type} ${col.primaryKey ? "PRIMARY KEY" : ""} ${col.notNull ? "NOT NULL" : ""}`)
                                .join(", ");
                            const query = `CREATE TABLE ${tableName} (${columnDefinitions});`;
                            yield client.execute(query);
                            returnData.push({ json: { success: true, message: `Table ${tableName} created` } });
                        }
                        else if (operation === "delete") {
                            const query = `DROP TABLE ${tableName};`;
                            yield client.execute(query);
                            returnData.push({ json: { success: true, message: `Table ${tableName} deleted` } });
                        }
                        else if (operation === "addColumn") {
                            const columnName = this.getNodeParameter("columnName", i, "");
                            const columnType = this.getNodeParameter("columnType", i, "");
                            const query = `ALTER TABLE ${tableName} ADD COLUMN ${columnName} ${columnType};`;
                            yield client.execute(query);
                            returnData.push({ json: { success: true, message: `Column ${columnName} added to table ${tableName}` } });
                        }
                    }
                    else if (resource === "row") {
                        const tableName = this.getNodeParameter("tableName", i, "");
                        if (operation === "insert") {
                            const data = this.getNodeParameter("data", i, "{}");
                            const parsedData = JSON.parse(data);
                            const columns = Object.keys(parsedData).join(", ");
                            const values = Object.values(parsedData);
                            const placeholders = values.map(() => "?").join(", ");
                            const query = `INSERT INTO ${tableName} (${columns}) VALUES (${placeholders});`;
                            const result = yield client.execute({ sql: query, args: values });
                            returnData.push({ json: { success: true, rowsAffected: result.rowsAffected } });
                        }
                        else if (operation === "update") {
                            const data = this.getNodeParameter("data", i, "{}");
                            const whereClause = this.getNodeParameter("whereClause", i, "");
                            const parsedData = JSON.parse(data);
                            const setClause = Object.keys(parsedData)
                                .map((key) => `${key} = ?`)
                                .join(", ");
                            const values = Object.values(parsedData);
                            const query = `UPDATE ${tableName} SET ${setClause} WHERE ${whereClause};`;
                            const result = yield client.execute({ sql: query, args: values });
                            returnData.push({ json: { success: true, rowsAffected: result.rowsAffected } });
                        }
                        else if (operation === "delete") {
                            const whereClause = this.getNodeParameter("whereClause", i, "");
                            const query = `DELETE FROM ${tableName} WHERE ${whereClause};`;
                            const result = yield client.execute(query);
                            returnData.push({ json: { success: true, rowsAffected: result.rowsAffected } });
                        }
                    }
                }
                catch (error) {
                    if (this.continueOnFail()) {
                        returnData.push({ json: { error: error.message } });
                        continue;
                    }
                    throw new n8n_workflow_1.NodeApiError(this.getNode(), error);
                }
            }
            return [this.helpers.returnJsonArray(returnData)];
        });
    }
}
exports.Turso = Turso;
