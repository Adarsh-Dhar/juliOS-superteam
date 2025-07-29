"use client";

import React from "react";
import RedditPosts from "@/components/RedditPosts";

export default function TestRedditPage() {
  return (
    <div className="min-h-screen bg-[#0A0F1F] text-white relative overflow-x-hidden">
      <div className="starfield" />
      <div className="max-w-7xl mx-auto p-6">
        <h1 className="text-3xl font-bold text-white mb-6 font-orbitron">
          Reddit Posts Test
        </h1>
        <RedditPosts campaignId="f5de022b-d687-487e-8f66-a338ac478d9c" />
      </div>
    </div>
  );
} 