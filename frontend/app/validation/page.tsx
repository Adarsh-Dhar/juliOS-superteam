"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { CheckCircle, AlertTriangle, Users, TrendingUp } from "lucide-react";
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert";

interface ValidationItem {
  id: string;
  cid: string;
  content: string;
  source: string;
  timestamp: string;
  metadata: any;
  decision?: string;
  confidence?: number;
  reputation?: number;
}

export default function ValidationPage() {
  const [items, setItems] = useState<ValidationItem[]>([]);
  const [selected, setSelected] = useState<ValidationItem | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // Fetch pending validation items
  useEffect(() => {
    const fetchItems = async () => {
      setLoading(true);
      setError("");
      try {
        const res = await fetch("/api/validation");
        const data = await res.json();
        // Only show items with no decision (pending)
        setItems(data.filter((v: any) => !v.decision));
      } catch (e) {
        setError("Failed to load validation items");
      }
      setLoading(false);
    };
    fetchItems();
  }, []);

  // Submit a vote
  const handleVote = async (vote: "authentic" | "suspicious") => {
    if (!selected) return;
    setLoading(true);
    setError("");
    setSuccess("");
    try {
      const res = await fetch("/api/validation", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          cid: selected.cid,
          decision: vote,
          confidence: 0.85, // Placeholder
          reputation: 1.0, // Placeholder
        }),
      });
      if (!res.ok) throw new Error("Vote failed");
      setSuccess("Vote submitted!");
      setItems((prev) => prev.filter((i) => i.cid !== selected.cid));
      setSelected(null);
    } catch (e) {
      setError("Failed to submit vote");
    }
    setLoading(false);
  };

  return (
    <div className="py-20 px-4 min-h-screen bg-gradient-to-br from-[#181c2b] to-[#232946]">
      <motion.div
        className="max-w-5xl mx-auto"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
      >
        <div className="text-center mb-12">
          <h2 className="text-4xl md:text-5xl font-orbitron font-bold mb-4 holographic-text">
            Content Validation
          </h2>
          <p className="text-xl text-gray-400 font-exo2">
            Help validate content for authenticity and safety
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Feed */}
          <div className="lg:col-span-1">
            <motion.div
              className="glassmorphism rounded-2xl p-6 h-[600px] overflow-hidden"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              <h3 className="text-xl font-orbitron font-semibold mb-6 text-center">
                Pending Items
              </h3>
              <div className="space-y-4 overflow-y-auto h-[500px] custom-scrollbar">
                <AnimatePresence>
                  {items.length === 0 && (
                    <p className="text-gray-400 text-center">No pending items.</p>
                  )}
                  {items.map((item, idx) => (
                    <motion.div
                      key={item.cid}
                      className={`glassmorphism rounded-xl p-4 cursor-pointer hover:scale-105 transition-transform ${selected?.cid === item.cid ? "border-2 border-blue-400" : ""}`}
                      initial={{ opacity: 0, y: 50 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -50 }}
                      transition={{ delay: idx * 0.05 }}
                      onClick={() => setSelected(item)}
                    >
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs text-gray-400">{new Date(item.timestamp).toLocaleString()}</span>
                        <span className="px-2 py-1 rounded-full text-xs border bg-yellow-500/20 border-yellow-500/50 text-yellow-400">
                          Pending
                        </span>
                      </div>
                      <p className="text-sm text-gray-300 mb-1 line-clamp-2">
                        {item.content}
                      </p>
                      <div className="flex items-center space-x-2 text-xs text-gray-400">
                        <Users className="w-3 h-3" />
                        <span>Source: {item.source}</span>
                        <TrendingUp className="w-3 h-3 ml-2" />
                        <span>Reputation: {item.reputation ?? "-"}</span>
                      </div>
                    </motion.div>
                  ))}
                </AnimatePresence>
              </div>
            </motion.div>
          </div>

          {/* Details & Voting */}
          <div className="lg:col-span-2">
            <motion.div
              className="glassmorphism rounded-2xl p-8 h-[600px] flex flex-col justify-center"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.3 }}
            >
              {selected ? (
                <motion.div
                  key={selected.cid}
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -30 }}
                  className="flex flex-col h-full justify-between"
                >
                  <div>
                    <h4 className="text-2xl font-bold mb-2 font-orbitron">Content Details</h4>
                    <p className="text-gray-300 font-exo2 mb-4 whitespace-pre-line">
                      {selected.content}
                    </p>
                    <div className="grid grid-cols-2 gap-4 mb-6">
                      <div className="text-center p-4 glassmorphism rounded-xl">
                        <div className="text-2xl font-bold text-blue-400">
                          {selected.reputation ?? "-"}
                        </div>
                        <div className="text-sm text-gray-400">Reputation</div>
                      </div>
                      <div className="text-center p-4 glassmorphism rounded-xl">
                        <div className="text-2xl font-bold text-green-400">
                          {selected.confidence ? `${selected.confidence}%` : "-"}
                        </div>
                        <div className="text-sm text-gray-400">Confidence</div>
                      </div>
                    </div>
                  </div>
                  <div>
                    <div className="flex space-x-4 mb-4">
                      <motion.button
                        className="flex-1 liquid-fill bg-green-500/20 border border-green-500/50 rounded-xl p-4 text-green-400 font-exo2 font-semibold disabled:opacity-50"
                        onClick={() => handleVote("authentic")}
                        disabled={loading}
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        <CheckCircle className="w-5 h-5 mx-auto mb-2" />
                        Authentic
                      </motion.button>
                      <motion.button
                        className="flex-1 liquid-fill bg-red-500/20 border border-red-500/50 rounded-xl p-4 text-red-400 font-exo2 font-semibold disabled:opacity-50"
                        onClick={() => handleVote("suspicious")}
                        disabled={loading}
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        <AlertTriangle className="w-5 h-5 mx-auto mb-2" />
                        Suspicious
                      </motion.button>
                    </div>
                    {error && (
                      <Alert variant="destructive" className="mb-2">
                        <AlertTitle>Error</AlertTitle>
                        <AlertDescription>{error}</AlertDescription>
                      </Alert>
                    )}
                    {success && (
                      <Alert className="mb-2">
                        <AlertTitle>Success</AlertTitle>
                        <AlertDescription>{success}</AlertDescription>
                      </Alert>
                    )}
                  </div>
                </motion.div>
              ) : (
                <div className="h-full flex items-center justify-center">
                  <p className="text-gray-400 font-exo2 text-lg">
                    Select an item from the feed to begin validation
                  </p>
                </div>
              )}
            </motion.div>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
