ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'contabilista';
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'auditor';
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'visualizador';

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS permissoes jsonb;