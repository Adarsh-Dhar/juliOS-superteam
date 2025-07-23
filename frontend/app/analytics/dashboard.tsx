import { useEffect, useState } from 'react';

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-lg shadow p-6 mb-6">
      <h2 className="text-xl font-bold mb-2">{title}</h2>
      {children}
    </div>
  );
}

export default function Dashboard() {
  const [agents, setAgents] = useState<any[]>([]);
  const [content, setContent] = useState<any[]>([]);
  const [analysis, setAnalysis] = useState<any[]>([]);
  const [validation, setValidation] = useState<any[]>([]);
  const [proofs, setProofs] = useState<any[]>([]);

  useEffect(() => {
    fetch('/api/agents').then(r => r.json()).then(setAgents);
    fetch('/api/content').then(r => r.json()).then(setContent);
    fetch('/api/analysis').then(r => r.json()).then(setAnalysis);
    fetch('/api/validation').then(r => r.json()).then(setValidation);
    fetch('/api/proof').then(r => r.json()).then(setProofs);
  }, []);

  return (
    <div className="max-w-5xl mx-auto py-10 px-4">
      <h1 className="text-3xl font-bold mb-8">Agent System Dashboard</h1>
      <Section title="Agents">
        <table className="min-w-full text-sm">
          <thead>
            <tr>
              <th className="text-left">Name</th>
              <th>Type</th>
              <th>Status</th>
              <th>Processed</th>
              <th>Accuracy</th>
              <th>Last Active</th>
            </tr>
          </thead>
          <tbody>
            {agents.map(agent => (
              <tr key={agent.id} className="border-t">
                <td>{agent.name}</td>
                <td>{agent.type}</td>
                <td>{agent.status}</td>
                <td>{agent.processedCount}</td>
                <td>{agent.accuracy}</td>
                <td>{agent.lastActiveAt ? new Date(agent.lastActiveAt).toLocaleString() : '-'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
      <Section title="Content Queue">
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr>
                <th className="text-left">CID</th>
                <th>Source</th>
                <th>Timestamp</th>
                <th>Content</th>
              </tr>
            </thead>
            <tbody>
              {content.slice(0, 10).map(item => (
                <tr key={item.id} className="border-t">
                  <td>{item.cid}</td>
                  <td>{item.source}</td>
                  <td>{new Date(item.timestamp).toLocaleString()}</td>
                  <td className="truncate max-w-xs">{item.content}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Section>
      <Section title="Analysis Results">
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr>
                <th className="text-left">CID</th>
                <th>Sentiment</th>
                <th>Engagement</th>
                <th>Red Flags</th>
                <th>Timestamp</th>
              </tr>
            </thead>
            <tbody>
              {analysis.slice(0, 10).map(res => (
                <tr key={res.id} className="border-t">
                  <td>{res.cid}</td>
                  <td>{res.sentiment}</td>
                  <td>{res.engagementScore}</td>
                  <td>{res.redFlags?.join(', ')}</td>
                  <td>{new Date(res.timestamp).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Section>
      <Section title="Validation Votes">
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr>
                <th className="text-left">CID</th>
                <th>Decision</th>
                <th>Confidence</th>
                <th>Reputation</th>
                <th>Timestamp</th>
              </tr>
            </thead>
            <tbody>
              {validation.slice(0, 10).map(vote => (
                <tr key={vote.id} className="border-t">
                  <td>{vote.cid}</td>
                  <td>{vote.decision}</td>
                  <td>{vote.confidence}</td>
                  <td>{vote.reputation}</td>
                  <td>{new Date(vote.createdAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Section>
      <Section title="Onchain Proofs">
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr>
                <th className="text-left">Content Hash</th>
                <th>Consensus Score</th>
                <th>Tx Hash</th>
                <th>Block</th>
                <th>Timestamp</th>
              </tr>
            </thead>
            <tbody>
              {proofs.slice(0, 10).map(proof => (
                <tr key={proof.id} className="border-t">
                  <td>{proof.contentHash}</td>
                  <td>{proof.consensusScore}</td>
                  <td className="truncate max-w-xs">{proof.txHash}</td>
                  <td>{proof.blockNumber}</td>
                  <td>{new Date(proof.timestamp).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Section>
    </div>
  );
} 