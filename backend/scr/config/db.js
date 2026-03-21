import { createClient } from "@supabase/supabase-js";

let supabase;

export function getDB() {
  if (supabase) return supabase;

  supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
  );

  console.log("Supabase connected");
  return supabase;
}