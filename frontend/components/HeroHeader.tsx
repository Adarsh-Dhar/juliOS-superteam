'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useEffect, useState } from 'react';
import { ChevronDown } from 'lucide-react';

interface Particle {
  id: number;
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  color: string;
}

export default function HeroHeader() {
  const [particles, setParticles] = useState<Particle[]>([]);
  const { scrollY } = useScroll();
  const opacity = useTransform(scrollY, [0, 300], [1, 0]);
  const scale = useTransform(scrollY, [0, 300], [1, 0.8]);

  useEffect(() => {
    const colors = ['#8A2BE2', '#4C6EF5', '#00F5A0', '#FF2A6D'];
    const newParticles: Particle[] = [];

    for (let i = 0; i < 200; i++) {
      newParticles.push({
        id: i,
        x: Math.random() * window.innerWidth,
        y: Math.random() * window.innerHeight,
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2,
        size: Math.random() * 3 + 1,
        color: colors[Math.floor(Math.random() * colors.length)],
      });
    }

    setParticles(newParticles);

    const animate = () => {
      setParticles(prev => prev.map(particle => ({
        ...particle,
        x: (particle.x + particle.vx + window.innerWidth) % window.innerWidth,
        y: (particle.y + particle.vy + window.innerHeight) % window.innerHeight,
      })));
    };

    const interval = setInterval(animate, 50);
    return () => clearInterval(interval);
  }, []);

  return (
    <motion.div 
      className="relative min-h-screen flex items-center justify-center overflow-hidden"
      style={{ opacity, scale }}
    >
      {/* Starfield Background */}
      <div className="starfield" />
      
      {/* Particle Swarm */}
      <div className="absolute inset-0">
        {particles.map((particle) => (
          <motion.div
            key={particle.id}
            className="absolute rounded-full"
            style={{
              left: particle.x,
              top: particle.y,
              width: particle.size,
              height: particle.size,
              backgroundColor: particle.color,
              boxShadow: `0 0 10px ${particle.color}`,
            }}
            animate={{
              scale: [1, 1.5, 1],
              opacity: [0.6, 1, 0.6],
            }}
            transition={{
              duration: 2 + Math.random() * 2,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
        ))}
      </div>

      {/* Main Content */}
      <div className="relative z-10 text-center px-4">
        <motion.h1
          className="text-6xl md:text-8xl lg:text-9xl font-orbitron font-bold mb-6 holographic-text"
          initial={{ opacity: 0, y: 100 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.5 }}
        >
          TRUSTGUARD
        </motion.h1>
        
        <motion.p
          className="text-xl md:text-2xl lg:text-3xl font-exo2 text-gray-300 mb-12"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1 }}
        >
          Decentralized Content Verification
        </motion.p>

        <motion.div
          className="inline-flex items-center space-x-4 text-sm font-exo2 text-gray-400"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 1, delay: 1.5 }}
        >
          <span className="px-3 py-1 rounded-full border border-purple-500/30 bg-purple-500/10">
            AI-Powered
          </span>
          <span className="px-3 py-1 rounded-full border border-blue-500/30 bg-blue-500/10">
            Real-time
          </span>
          <span className="px-3 py-1 rounded-full border border-green-500/30 bg-green-500/10">
            Blockchain Verified
          </span>
        </motion.div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2"
        animate={{ y: [0, 10, 0] }}
        transition={{ duration: 2, repeat: Infinity }}
      >
        <ChevronDown className="w-6 h-6 text-gray-400" />
      </motion.div>
    </motion.div>
  );
}