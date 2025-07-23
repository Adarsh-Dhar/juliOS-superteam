"use client";
import React, { useEffect, useState } from "react";

const AGENT_TYPE = "REPORTER";

function classNames(...classes: string[]) {
  return classes.filter(Boolean).join(" ");
}

export default function ReporterDashboard() {
  const [agents, setAgents] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const [proofs, setProofs] = useState<any[]>([]);
  const [proofsLoading, setProofsLoading] = useState(false);

  async function fetchAgents() {
    setLoading(true);
    setError("");
    try {
      const res = await fetch("/api/agents");
      const data = await res.json();
      setAgents(data.filter((a: any) => a.type === AGENT_TYPE));
    } catch (e) {
      setError("Failed to fetch agents");
    }
    setLoading(false);
  }

  async function fetchProofs() {
    setProofsLoading(true);
    try {
      const res = await fetch("/api/proof");
      const data = await res.json();
      setProofs(data);
    } catch (e) {
      // ignore for now
    }
    setProofsLoading(false);
  }

  useEffect(() => {
    fetchAgents();
    fetchProofs();
  }, []);

  async function addAgent(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      const res = await fetch("/api/agents", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: AGENT_TYPE, name }),
      });
      if (!res.ok) throw new Error("Failed to add agent");
      setName("");
      fetchAgents();
    } catch (e) {
      setError("Failed to add agent");
    }
    setLoading(false);
  }

  async function removeAgent(id: string) {
    setLoading(true);
    setError("");
    try {
      await fetch(`/api/agents/${id}`, { method: "DELETE" });
      fetchAgents();
    } catch (e) {
      setError("Failed to remove agent");
    }
    setLoading(false);
  }

  async function updateAgentStatus(id: string, status: string) {
    setLoading(true);
    setError("");
    try {
      await fetch(`/api/agents/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status }),
      });
      fetchAgents();
    } catch (e) {
      setError("Failed to update agent");
    }
    setLoading(false);
  }

  return (
    <div className="max-w-5xl mx-auto py-10 px-4">
      <h1 className="text-3xl font-bold mb-6 text-center">Reporter Agents</h1>
      <form onSubmit={addAgent} className="flex gap-2 mb-8 justify-center">
        <input
          type="text"
          className="input input-bordered w-full max-w-xs border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="New reporter name"
          value={name}
          onChange={e => setName(e.target.value)}
          required
        />
        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition"
          disabled={loading || !name.trim()}
        >
          Add
        </button>
      </form>
      {error && <div className="text-red-500 mb-4 text-center">{error}</div>}
      <div className="overflow-x-auto mb-12">
        <table className="min-w-full bg-white border rounded shadow">
          <thead>
            <tr className="bg-gray-100">
              <th className="py-2 px-4 text-left">Name</th>
              <th className="py-2 px-4 text-left">Status</th>
              <th className="py-2 px-4 text-left">Processed</th>
              <th className="py-2 px-4 text-left">Accuracy</th>
              <th className="py-2 px-4 text-left">Last Active</th>
              <th className="py-2 px-4">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={6} className="text-center py-6">Loading...</td>
              </tr>
            ) : agents.length === 0 ? (
              <tr>
                <td colSpan={6} className="text-center py-6 text-gray-400">No reporter agents found.</td>
              </tr>
            ) : (
              agents.map(agent => (
                <tr key={agent.id} className="border-t">
                  <td className="py-2 px-4 font-medium">{agent.name}</td>
                  <td className="py-2 px-4">
                    <span className={classNames(
                      "inline-block px-2 py-1 rounded text-xs font-semibold",
                      agent.status === "ACTIVE"
                        ? "bg-green-100 text-green-700"
                        : agent.status === "OFFLINE"
                        ? "bg-gray-200 text-gray-500"
                        : "bg-yellow-100 text-yellow-700"
                    )}>
                      {agent.status}
                    </span>
                  </td>
                  <td className="py-2 px-4">{agent.processedCount}</td>
                  <td className="py-2 px-4">{agent.accuracy?.toFixed(2)}</td>
                  <td className="py-2 px-4">{agent.lastActiveAt ? new Date(agent.lastActiveAt).toLocaleString() : "-"}</td>
                  <td className="py-2 px-4 flex gap-2">
                    <button
                      className="bg-blue-500 text-white px-2 py-1 rounded hover:bg-blue-600 text-xs"
                      onClick={() => updateAgentStatus(agent.id, agent.status === "ACTIVE" ? "OFFLINE" : "ACTIVE")}
                      disabled={loading}
                    >
                      {agent.status === "ACTIVE" ? "Stop" : "Start"}
                    </button>
                    <button
                      className="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600 text-xs"
                      onClick={() => removeAgent(agent.id)}
                      disabled={loading}
                    >
                      Remove
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <h2 className="text-2xl font-bold mb-4 text-center">Recent On-Chain Proofs</h2>
      <div className="overflow-x-auto">
        <table className="min-w-full bg-white border rounded shadow">
          <thead>
            <tr className="bg-gray-100">
              <th className="py-2 px-4 text-left">Content Hash</th>
              <th className="py-2 px-4 text-left">Consensus Score</th>
              <th className="py-2 px-4 text-left">Tx Hash</th>
              <th className="py-2 px-4 text-left">Block #</th>
              <th className="py-2 px-4 text-left">Timestamp</th>
            </tr>
          </thead>
          <tbody>
            {proofsLoading ? (
              <tr>
                <td colSpan={5} className="text-center py-6">Loading...</td>
              </tr>
            ) : proofs.length === 0 ? (
              <tr>
                <td colSpan={5} className="text-center py-6 text-gray-400">No proofs found.</td>
              </tr>
            ) : (
              proofs.map((proof: any) => (
                <tr key={proof.id} className="border-t">
                  <td className="py-2 px-4 font-mono text-xs break-all">{proof.contentHash}</td>
                  <td className="py-2 px-4">{proof.consensusScore}</td>
                  <td className="py-2 px-4 font-mono text-xs break-all">{proof.txHash}</td>
                  <td className="py-2 px-4">{proof.blockNumber}</td>
                  <td className="py-2 px-4">{proof.timestamp ? new Date(proof.timestamp).toLocaleString() : "-"}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
