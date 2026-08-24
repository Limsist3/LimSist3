-- PACOTES SMS
CREATE TABLE public.sms_pacotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  quantidade_sms integer NOT NULL,
  preco numeric NOT NULL DEFAULT 0,
  numero_mpesa text,
  numero_emola text,
  nome_titular text,
  validade_dias integer NOT NULL DEFAULT 30,
  ativo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.sms_pacotes TO authenticated;
GRANT ALL ON public.sms_pacotes TO service_role;
ALTER TABLE public.sms_pacotes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sms_pacotes_select" ON public.sms_pacotes FOR SELECT TO authenticated USING (true);
CREATE POLICY "sms_pacotes_admin" ON public.sms_pacotes FOR ALL TO authenticated
  USING (public.is_superadmin(auth.uid())) WITH CHECK (public.is_superadmin(auth.uid()));
GRANT INSERT, UPDATE, DELETE ON public.sms_pacotes TO authenticated;

-- SALDO SMS
CREATE TABLE public.sms_saldos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  saldo integer NOT NULL DEFAULT 0,
  total_enviadas integer NOT NULL DEFAULT 0,
  expira_em timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.sms_saldos TO authenticated;
GRANT INSERT, UPDATE ON public.sms_saldos TO authenticated;
GRANT ALL ON public.sms_saldos TO service_role;
ALTER TABLE public.sms_saldos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sms_saldos_own_select" ON public.sms_saldos FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_superadmin(auth.uid()));
CREATE POLICY "sms_saldos_admin_write" ON public.sms_saldos FOR INSERT TO authenticated
  WITH CHECK (public.is_superadmin(auth.uid()) OR user_id = auth.uid());
CREATE POLICY "sms_saldos_admin_update" ON public.sms_saldos FOR UPDATE TO authenticated
  USING (public.is_superadmin(auth.uid())) WITH CHECK (public.is_superadmin(auth.uid()));

-- CONFIG DE ENVIO
CREATE TABLE public.sms_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  ativo boolean NOT NULL DEFAULT false,
  nome_remetente text,
  hora_envio integer NOT NULL DEFAULT 8,
  aviso_3_dias_antes boolean NOT NULL DEFAULT true,
  aviso_no_dia boolean NOT NULL DEFAULT true,
  aviso_2_dias_depois boolean NOT NULL DEFAULT true,
  template_antes text NOT NULL DEFAULT 'Prezado(a) {nome}, a sua prestacao de {valor} MT vence em {dias} dias ({data}). {instituicao}',
  template_dia text NOT NULL DEFAULT 'Prezado(a) {nome}, a sua prestacao de {valor} MT vence hoje ({data}). {instituicao}',
  template_depois text NOT NULL DEFAULT 'Prezado(a) {nome}, a sua prestacao de {valor} MT venceu em {data} e encontra-se em atraso. {instituicao}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.sms_config TO authenticated;
GRANT ALL ON public.sms_config TO service_role;
ALTER TABLE public.sms_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sms_config_own" ON public.sms_config FOR ALL TO authenticated
  USING (user_id = auth.uid() OR public.is_superadmin(auth.uid()))
  WITH CHECK (user_id = auth.uid() OR public.is_superadmin(auth.uid()));
GRANT DELETE ON public.sms_config TO authenticated;

-- RECARGAS
CREATE TABLE public.sms_recargas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  pacote_id uuid REFERENCES public.sms_pacotes(id),
  quantidade_sms integer NOT NULL DEFAULT 0,
  valor numeric NOT NULL DEFAULT 0,
  metodo_pagamento text NOT NULL DEFAULT 'mpesa',
  codigo_transacao text,
  comprovativo_url text,
  status text NOT NULL DEFAULT 'pendente',
  motivo_rejeicao text,
  validado_por uuid,
  validado_em timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.sms_recargas TO authenticated;
GRANT ALL ON public.sms_recargas TO service_role;
ALTER TABLE public.sms_recargas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sms_recargas_select" ON public.sms_recargas FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_superadmin(auth.uid()));
CREATE POLICY "sms_recargas_insert" ON public.sms_recargas FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "sms_recargas_update_admin" ON public.sms_recargas FOR UPDATE TO authenticated
  USING (public.is_superadmin(auth.uid())) WITH CHECK (public.is_superadmin(auth.uid()));

-- HISTORICO DE ENVIOS
CREATE TABLE public.sms_envios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  cliente_id uuid,
  emprestimo_id uuid,
  telefone text NOT NULL,
  mensagem text NOT NULL,
  tipo text NOT NULL DEFAULT 'manual',
  referencia_data date,
  status text NOT NULL DEFAULT 'enviado',
  erro text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX sms_envios_dedup ON public.sms_envios (user_id, emprestimo_id, tipo, referencia_data)
  WHERE emprestimo_id IS NOT NULL AND referencia_data IS NOT NULL;
CREATE INDEX sms_envios_user_created ON public.sms_envios (user_id, created_at DESC);
GRANT SELECT, INSERT ON public.sms_envios TO authenticated;
GRANT ALL ON public.sms_envios TO service_role;
ALTER TABLE public.sms_envios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sms_envios_select" ON public.sms_envios FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_superadmin(auth.uid()));
CREATE POLICY "sms_envios_insert" ON public.sms_envios FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- TRIGGERS updated_at
CREATE TRIGGER trg_sms_pacotes_updated BEFORE UPDATE ON public.sms_pacotes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_sms_saldos_updated BEFORE UPDATE ON public.sms_saldos
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_sms_config_updated BEFORE UPDATE ON public.sms_config
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_sms_recargas_updated BEFORE UPDATE ON public.sms_recargas
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- CREDITAR SMS (superadmin ou service_role)
CREATE OR REPLACE FUNCTION public.sms_creditar(p_user_id uuid, p_quantidade integer, p_dias integer DEFAULT 30)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_saldo_actual integer := 0;
  v_expira timestamptz;
BEGIN
  IF auth.uid() IS NOT NULL AND NOT public.is_superadmin(auth.uid()) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Sem permissao');
  END IF;

  SELECT saldo, expira_em INTO v_saldo_actual, v_expira
  FROM public.sms_saldos WHERE user_id = p_user_id;

  IF v_expira IS NOT NULL AND v_expira < now() THEN
    v_saldo_actual := 0;
  END IF;

  INSERT INTO public.sms_saldos (user_id, saldo, expira_em)
  VALUES (p_user_id, GREATEST(p_quantidade, 0), now() + (p_dias || ' days')::interval)
  ON CONFLICT (user_id) DO UPDATE
    SET saldo = GREATEST(COALESCE(v_saldo_actual, 0), 0) + GREATEST(p_quantidade, 0),
        expira_em = now() + (p_dias || ' days')::interval,
        updated_at = now();

  RETURN jsonb_build_object('success', true);
END;
$$;

-- DEFINIR SALDO EXACTO (superadmin)
CREATE OR REPLACE FUNCTION public.sms_definir_saldo(p_user_id uuid, p_saldo integer, p_dias integer DEFAULT 30)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NOT NULL AND NOT public.is_superadmin(auth.uid()) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Sem permissao');
  END IF;

  INSERT INTO public.sms_saldos (user_id, saldo, expira_em)
  VALUES (p_user_id, GREATEST(p_saldo, 0), now() + (p_dias || ' days')::interval)
  ON CONFLICT (user_id) DO UPDATE
    SET saldo = GREATEST(p_saldo, 0),
        expira_em = now() + (p_dias || ' days')::interval,
        updated_at = now();

  RETURN jsonb_build_object('success', true);
END;
$$;

-- CONSUMIR SMS
CREATE OR REPLACE FUNCTION public.sms_consumir(p_user_id uuid, p_quantidade integer DEFAULT 1)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_saldo integer;
  v_expira timestamptz;
BEGIN
  SELECT saldo, expira_em INTO v_saldo, v_expira
  FROM public.sms_saldos WHERE user_id = p_user_id FOR UPDATE;

  IF v_saldo IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Sem saldo de SMS');
  END IF;

  IF v_expira IS NOT NULL AND v_expira < now() THEN
    UPDATE public.sms_saldos SET saldo = 0, updated_at = now() WHERE user_id = p_user_id;
    RETURN jsonb_build_object('success', false, 'error', 'Saldo de SMS expirado');
  END IF;

  IF v_saldo < p_quantidade THEN
    RETURN jsonb_build_object('success', false, 'error', 'Saldo de SMS insuficiente');
  END IF;

  UPDATE public.sms_saldos
    SET saldo = saldo - p_quantidade,
        total_enviadas = total_enviadas + p_quantidade,
        updated_at = now()
    WHERE user_id = p_user_id;

  RETURN jsonb_build_object('success', true, 'saldo_restante', v_saldo - p_quantidade);
END;
$$;

-- APROVAR RECARGA (superadmin)
CREATE OR REPLACE FUNCTION public.sms_aprovar_recarga(p_recarga_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rec record;
  v_dias integer := 30;
BEGIN
  IF NOT public.is_superadmin(auth.uid()) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Sem permissao');
  END IF;

  SELECT * INTO v_rec FROM public.sms_recargas WHERE id = p_recarga_id;
  IF v_rec IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Pedido nao encontrado');
  END IF;
  IF v_rec.status = 'aprovado' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Pedido ja aprovado');
  END IF;

  IF v_rec.pacote_id IS NOT NULL THEN
    SELECT COALESCE(validade_dias, 30) INTO v_dias FROM public.sms_pacotes WHERE id = v_rec.pacote_id;
  END IF;

  PERFORM public.sms_creditar(v_rec.user_id, v_rec.quantidade_sms, COALESCE(v_dias, 30));

  UPDATE public.sms_recargas
    SET status = 'aprovado', validado_por = auth.uid(), validado_em = now(), updated_at = now()
    WHERE id = p_recarga_id;

  INSERT INTO public.notificacoes (user_id, titulo, mensagem, tipo, enviado_por)
  VALUES (v_rec.user_id, 'Recarga de SMS aprovada',
    'Foram creditadas ' || v_rec.quantidade_sms || ' SMS na sua conta. Validade: ' || v_dias || ' dias.',
    'info', auth.uid());

  RETURN jsonb_build_object('success', true);
END;
$$;

-- REJEITAR RECARGA (superadmin)
CREATE OR REPLACE FUNCTION public.sms_rejeitar_recarga(p_recarga_id uuid, p_motivo text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user uuid;
BEGIN
  IF NOT public.is_superadmin(auth.uid()) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Sem permissao');
  END IF;

  UPDATE public.sms_recargas
    SET status = 'rejeitado', motivo_rejeicao = p_motivo, validado_por = auth.uid(), validado_em = now(), updated_at = now()
    WHERE id = p_recarga_id
    RETURNING user_id INTO v_user;

  IF v_user IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Pedido nao encontrado');
  END IF;

  INSERT INTO public.notificacoes (user_id, titulo, mensagem, tipo, enviado_por)
  VALUES (v_user, 'Recarga de SMS rejeitada', COALESCE(p_motivo, 'Comprovativo invalido'), 'aviso', auth.uid());

  RETURN jsonb_build_object('success', true);
END;
$$;

-- PACOTES INICIAIS
INSERT INTO public.sms_pacotes (nome, quantidade_sms, preco, numero_mpesa, numero_emola, nome_titular)
VALUES
  ('Pacote SMS 100', 100, 250, '840000000', '860000000', 'LIMSist'),
  ('Pacote SMS 500', 500, 1000, '840000000', '860000000', 'LIMSist'),
  ('Pacote SMS 2000', 2000, 3500, '840000000', '860000000', 'LIMSist');