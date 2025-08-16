# n8n Node for Turso DB

This is an n8n node for interacting with a Turso DB database.

## Installation

To use this node, you need to install it in your n8n instance.

### For Proxmox Container

1.  **Access the Proxmox container:**
    You will need shell access to your n8n container. You can usually get this through the Proxmox console or by connecting via SSH.

2.  **Place the node code in the container:**
    The easiest way is to clone the git repository directly into your container.
    *   **Install git if it is not already installed:**
        `apt-get update && apt-get install -y git`
    *   **Clone your repository:**
        `git clone <URL_de_votre_repertoire_git>`
    This will create a directory containing the node code. Note the full path to this directory (e.g., `/root/my-project/n8n-nodes-turso`).

3.  **Install the node dependencies:**
    Navigate to the node directory and install the dependencies:
    `cd /path/to/your/n8n-nodes-turso`
    `npm install`

4.  **Configure n8n to load the node:**
    You need to tell n8n where to find your custom node. To do this, you need to set an environment variable. The way to do this depends on how you start n8n in your container.
    *   **If you are using a systemd service to start n8n:**
        1.  Edit the n8n service file (e.g., `/etc/systemd/system/n8n.service`).
        2.  Add the following line in the `[Service]` section:
            `Environment="N8N_CUSTOM_EXTENSIONS_PATH=/path/to/your/n8n-nodes-turso"`
        3.  Reload the systemd configuration and restart n8n:
            `systemctl daemon-reload`
            `systemctl restart n8n`
    *   **If you start n8n manually:**
        You can set the environment variable before launching n8n:
        `export N8N_CUSTOM_EXTENSIONS_PATH=/path/to/your/n8n-nodes-turso`
        `n8n`

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
*   **Add Column**: Adds a column to an existing table.

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
