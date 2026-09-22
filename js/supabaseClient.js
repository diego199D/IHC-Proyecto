/* =========================================================
   Conexión a Supabase
   Reemplaza estos dos valores por los de tu proyecto:
   Project Settings → API → Project URL / anon public key
   ========================================================= */
const SUPABASE_URL = 'https://uhofygmlqevyjwjamtaw.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_zKBXzkjF61Q5AL-8nfxQLg_25J7OvRK';

const db = (SUPABASE_URL.startsWith('http'))
  ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : null;

if (!db) {
  console.warn('Supabase no está configurado todavía: completa SUPABASE_URL y SUPABASE_ANON_KEY en js/supabaseClient.js');
}
