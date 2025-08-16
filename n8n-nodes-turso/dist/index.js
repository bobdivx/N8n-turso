"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.credentials = exports.nodes = void 0;
const Turso_node_1 = require("./nodes/Turso.node");
const TursoApi_credentials_1 = require("./credentials/TursoApi.credentials");
exports.nodes = [Turso_node_1.Turso];
exports.credentials = [TursoApi_credentials_1.TursoApi];
