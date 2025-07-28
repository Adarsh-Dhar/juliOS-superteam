import './globals.css';
import type { Metadata } from 'next';
import { Inter, Orbitron, Exo_2 } from 'next/font/google';
import { SolanaProvider } from '../components/SolanaProvider';
import { Toaster } from '@/components/ui/toaster';

const inter = Inter({ subsets: ['latin'] });
const orbitron = Orbitron({ 
  subsets: ['latin'],
  variable: '--font-orbitron',
  weight: ['400', '500', '600', '700', '800', '900']
});
const exo2 = Exo_2({ 
  subsets: ['latin'],
  variable: '--font-exo2',
  weight: ['300', '400', '500', '600', '700']
});

export const metadata: Metadata = {
  title: 'TrustGuard - Decentralized Content Verification',
  description: 'Advanced AI-powered content verification dashboard',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${orbitron.variable} ${exo2.variable}`}>
      <SolanaProvider>
      <body className={`${inter.className} bg-[#0A0F1F] text-white overflow-x-hidden`}>
        {children}
        <Toaster />
      </body>
      </SolanaProvider>
    </html>
  );
}