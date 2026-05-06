-- ════════════════════════════════════════════════════════════════════
-- Admin allowlist + admin-aware RLS for the Preparing You admin app
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.prep_admins (
  user_id  UUID PRIMARY KEY REFERENCES public.prep_users(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ DEFAULT now()
);

-- Anyone signed in can READ the admin list (so the admin app can verify itself).
ALTER TABLE public.prep_admins ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "any signed-in reads prep_admins" ON public.prep_admins;
CREATE POLICY "any signed-in reads prep_admins" ON public.prep_admins
  FOR SELECT USING (auth.role() = 'authenticated');

-- Helper: is the current request from an admin?
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.prep_admins WHERE user_id = auth.uid())
$$;

-- ── Open admin read+write access on every prep_* table ──
DO $$ DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
      'prep_users','prep_pcms','prep_books','prep_chapters','prep_articles',
      'prep_signoffs','prep_paul_chats','prep_book_chunks',
      'prep_pcm_elections','prep_messages','prep_townhalls','prep_townhall_hosts',
      'prep_admins'
    ])
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS "admin reads all %1$s" ON public.%1$s', t);
    EXECUTE format('CREATE POLICY "admin reads all %1$s" ON public.%1$s FOR SELECT USING (public.is_admin())', t);
    EXECUTE format('DROP POLICY IF EXISTS "admin writes all %1$s" ON public.%1$s', t);
    EXECUTE format('CREATE POLICY "admin writes all %1$s" ON public.%1$s FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin())', t);
  END LOOP;
END $$;

-- Seed initial admin: markofmelb@gmail.com
INSERT INTO public.prep_admins (user_id)
SELECT id FROM public.prep_users WHERE email = 'markofmelb@gmail.com'
ON CONFLICT (user_id) DO NOTHING;
