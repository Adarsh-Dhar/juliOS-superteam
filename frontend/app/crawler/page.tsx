"use client";
import React, { useEffect, useState } from "react";
import { useToast } from "@/hooks/use-toast";

const AGENT_TYPE = "CRAWLER";
const AGENT_STATES = ["RUNNING", "PAUSED", "STOPPED"];

function classNames(...classes: string[]) {
  return classes.filter(Boolean).join(" ");
}

export default function CrawlerDashboard() {
  const [agents, setAgents] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const [globalLoading, setGlobalLoading] = useState(false);
  const { toast } = useToast();
  const [editingAgentId, setEditingAgentId] = useState<string | null>(null);
  const [editingState, setEditingState] = useState<string>("");

  async function fetchAgents() {
    setLoading(true);
    setError("");
    try {
      const res = await fetch("/api/agents");
      const data = await res.json();
      // If type is present, filter by CRAWLER, else show all
      setAgents(Array.isArray(data) ? data.filter((a: any) => a.type ? a.type === AGENT_TYPE : true) : []);
    } catch (e) {
      setError("Failed to fetch agents");
      toast({ title: "Error", description: "Failed to fetch agents" });
    }
    setLoading(false);
  }

  useEffect(() => {
    fetchAgents();
  }, []);

  async function addAgent(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      const res = await fetch("/api/agents", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: AGENT_TYPE, name, status: "ACTIVE" }),
      });
      if (!res.ok) throw new Error("Failed to add agent");
      setName("");
      fetchAgents();
      toast({ title: "Agent Added", description: "Crawler agent added successfully." });
    } catch (e) {
      setError("Failed to add agent");
      console.error("Failed to add agent", e);
      toast({ title: "Error", description: "Failed to add agent" });
    }
    setLoading(false);
  }

  async function removeAgent(id: string) {
    setLoading(true);
    setError("");
    try {
      await fetch(`/api/agents/${id}`, { method: "DELETE" });
      fetchAgents();
      toast({ title: "Agent Removed", description: "Crawler agent removed." });
    } catch (e) {
      setError("Failed to remove agent");
      toast({ title: "Error", description: "Failed to remove agent" });
    }
    setLoading(false);
  }

  async function updateAgentStatus(id: string, state: string) {
    setLoading(true);
    setError("");
    try {
      await fetch(`/api/agents/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ state }),
      });
      fetchAgents();
      toast({ title: "Status Updated", description: `Agent status set to ${state}` });
    } catch (e) {
      setError("Failed to update agent");
      toast({ title: "Error", description: "Failed to update agent" });
    }
    setLoading(false);
    setEditingAgentId(null);
    setEditingState("");
  }

  async function sendGlobalAction(action: string) {
    setGlobalLoading(true);
    setError("");
    try {
      await fetch("/api/network/control", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action }),
      });
      toast({ title: "Action Sent", description: `${action.replace("_", " ")}` });
    } catch (e) {
      setError("Failed to send global action");
      toast({ title: "Error", description: "Failed to send global action" });
    }
    setGlobalLoading(false);
  }

  return (
    <div className="max-w-3xl mx-auto py-10 px-4 text-white">
      <h1 className="text-3xl font-bold mb-6 text-center holographic-text">Crawler Agents</h1>
      <form onSubmit={addAgent} className="flex gap-2 mb-8 justify-center">
        <input
          type="text"
          className="input input-bordered w-full max-w-xs border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-[#181c2b] text-white placeholder-gray-400"
          placeholder="New crawler name"
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
      <div className="mb-8 flex gap-4 justify-center">
        <button
          className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 transition disabled:opacity-50"
          onClick={() => sendGlobalAction("BOOST_CRAWLERS")}
          disabled={globalLoading}
        >
          Boost Crawlers
        </button>
        <button
          className="bg-yellow-500 text-white px-4 py-2 rounded hover:bg-yellow-600 transition disabled:opacity-50"
          onClick={() => sendGlobalAction("FAST_TRACK")}
          disabled={globalLoading}
        >
          Fast Track
        </button>
        <button
          className="bg-gray-700 text-white px-4 py-2 rounded hover:bg-gray-800 transition disabled:opacity-50"
          onClick={() => sendGlobalAction("GLOBAL_SYNC")}
          disabled={globalLoading}
        >
          Global Sync
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full glassmorphism border rounded shadow text-white">
          <thead>
            <tr className="bg-gray-800">
              <th className="py-2 px-4 text-left font-exo2 text-gray-300">Name</th>
              <th className="py-2 px-4 text-left font-exo2 text-gray-300">Status</th>
              <th className="py-2 px-4 text-left font-exo2 text-gray-300">Processed</th>
              <th className="py-2 px-4 text-left font-exo2 text-gray-300">Accuracy</th>
              <th className="py-2 px-4 text-left font-exo2 text-gray-300">Last Active</th>
              <th className="py-2 px-4 font-exo2 text-gray-300">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={6} className="text-center py-6 text-gray-400">Loading...</td>
              </tr>
            ) : agents.length === 0 ? (
              <tr>
                <td colSpan={6} className="text-center py-6 text-gray-500">No crawler agents found.</td>
              </tr>
            ) : (
              agents.map(agent => (
                <tr key={agent.id} className="border-t border-gray-700 hover:bg-gray-900 transition">
                  <td className="py-2 px-4 font-medium text-white">{agent.name}</td>
                  <td className="py-2 px-4">
                    <span className={classNames(
                      "inline-block px-2 py-1 rounded text-xs font-semibold",
                      (agent.state === "RUNNING" || agent.status === "ACTIVE")
                        ? "bg-green-900 text-green-400"
                        : (agent.state === "STOPPED" || agent.status === "OFFLINE")
                        ? "bg-gray-800 text-gray-400"
                        : "bg-yellow-900 text-yellow-400"
                    )}>
                      {agent.state || agent.status}
                    </span>
                  </td>
                  <td className="py-2 px-4 text-gray-200">{agent.processedCount ?? '-'}</td>
                  <td className="py-2 px-4 text-gray-200">{agent.accuracy !== undefined ? agent.accuracy.toFixed(2) : '-'}</td>
                  <td className="py-2 px-4 text-gray-400">{agent.lastActiveAt ? new Date(agent.lastActiveAt).toLocaleString() : "-"}</td>
                  <td className="py-2 px-4 flex gap-2 items-center">
                    {editingAgentId === agent.id ? (
                      <>
                        <select
                          className="bg-gray-800 text-white px-2 py-1 rounded border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500 text-xs"
                          value={editingState}
                          onChange={e => setEditingState(e.target.value)}
                        >
                          <option value="" disabled>Select state</option>
                          {AGENT_STATES.map(state => (
                            <option key={state} value={state}>{state}</option>
                          ))}
                        </select>
                        <button
                          className="bg-green-600 text-white px-2 py-1 rounded hover:bg-green-700 text-xs ml-2"
                          onClick={() => updateAgentStatus(agent.id, editingState)}
                          disabled={loading || !editingState}
                        >
                          Save
                        </button>
                        <button
                          className="bg-gray-500 text-white px-2 py-1 rounded hover:bg-gray-600 text-xs ml-1"
                          onClick={() => { setEditingAgentId(null); setEditingState(""); }}
                          disabled={loading}
                        >
                          Cancel
                        </button>
                      </>
                    ) : (
                      <>
                        <button
                          className="bg-blue-500 text-white px-2 py-1 rounded hover:bg-blue-600 text-xs"
                          onClick={() => { setEditingAgentId(agent.id); setEditingState(agent.state || ""); }}
                          disabled={loading}
                        >
                          Edit
                        </button>
                        <button
                          className="bg-blue-500 text-white px-2 py-1 rounded hover:bg-blue-600 text-xs"
                          onClick={() => updateAgentStatus(agent.id, agent.status === "ACTIVE" ? "STOPPED" : "RUNNING")}
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
                      </>
                    )}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
