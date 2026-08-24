ALTER TABLE public.configuracao_pagamento
  ADD COLUMN IF NOT EXISTS numero_notificacoes text;

ALTER TABLE public.subscription_requests
  ALTER COLUMN codigo_submetido DROP NOT NULL;

CREATE OR REPLACE FUNCTION public.criar_pedido_subscricao(p_pacote_id uuid, p_metodo text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_pacote RECORD;
  v_id uuid;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Sessão inválida.');
  END IF;

  IF p_metodo NOT IN ('mpesa', 'emola') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Método de pagamento inválido.');
  END IF;

  SELECT * INTO v_pacote FROM pacotes_plataforma WHERE id = p_pacote_id AND ativo = true;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Pacote não encontrado.');
  END IF;

  IF EXISTS (
    SELECT 1 FROM subscription_requests
    WHERE user_id = v_uid AND status = 'pendente' AND created_at > now() - interval '2 hours'
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Já tem um pedido pendente em análise.');
  END IF;

  INSERT INTO subscription_requests (user_id, plano, valor_esperado, metodo_pagamento, codigo_submetido, status)
  VALUES (v_uid, v_pacote.nome, v_pacote.preco, p_metodo, NULL, 'pendente')
  RETURNING id INTO v_id;

  RETURN jsonb_build_object('success', true, 'id', v_id, 'pacote', v_pacote.nome, 'valor', v_pacote.preco);
END;
$$;

GRANT EXECUTE ON FUNCTION public.criar_pedido_subscricao(uuid, text) TO authenticated;