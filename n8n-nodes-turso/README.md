# n8n Node for Turso DB

This is an n8n node for interacting with a Turso DB database.

## Installation

To use this node, you need to install it in your n8n instance.

## Configuration

You need to configure the credentials for the Turso DB node.
1.  Go to the "Credentials" section in n8n.
2.  Click on "Add credential".
3.  Search for "Turso API" and click on it.
4.  Enter your Turso database URL and auth token.

## Operations

This node supports the following operations:

### Query
*   **Execute**: Executes a raw SQL query.

### Table
*   **Create**: Creates a new table.
*   **Delete**: Deletes a table.

### Row
*   **Insert**: Inserts a new row into a table.
*   **Update**: Updates a row in a table.
*   **Delete**: Deletes a row from a table.

## Usage

1.  Add the Turso node to your workflow.
2.  Select the credentials you configured.
3.  Select the "Resource" and "Operation" you want to perform.
4.  Fill in the required fields.
5.  Execute the workflow.
