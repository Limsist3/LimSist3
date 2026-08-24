ALTER TABLE public.configuracoes_empresa
  ADD COLUMN IF NOT EXISTS capitalizacao_automatica boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS capitalizacao_dias_carencia integer NOT NULL DEFAULT 3;

ALTER TABLE public.emprestimos
  ADD COLUMN IF NOT EXISTS capitalizado boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS capitalizado_em timestamp with time zone,
  ADD COLUMN IF NOT EXISTS valor_capitalizado numeric NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public.aplicar_capitalizacao_automatica(p_user_id uuid DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rec record;
  v_saldo numeric;
  v_juros numeric;
  v_count integer := 0;
  v_total numeric := 0;
BEGIN
  FOR v_rec IN
    SELECT e.id, e.valor_total, e.valor_pago, e.taxa_juros
    FROM public.emprestimos e
    JOIN public.configuracoes_empresa c ON c.user_id = e.user_id
    WHERE c.capitalizacao_automatica = true
      AND e.capitalizado = false
      AND COALESCE(e.status, '') <> 'pago'
      AND e.data_reembolso IS NOT NULL
      AND e.data_reembolso + (COALESCE(c.capitalizacao_dias_carencia, 3) || ' days')::interval < now()
      AND (p_user_id IS NULL OR e.user_id = p_user_id)
      AND COALESCE(e.valor_total, 0) - COALESCE(e.valor_pago, 0) > 0
  LOOP
    v_saldo := COALESCE(v_rec.valor_total, 0) - COALESCE(v_rec.valor_pago, 0);
    v_juros := round((v_saldo * COALESCE(v_rec.taxa_juros, 0) / 100)::numeric, 2);

    IF v_juros > 0 THEN
      UPDATE public.emprestimos
      SET valor_total = COALESCE(valor_total, 0) + v_juros,
          valor_capitalizado = COALESCE(valor_capitalizado, 0) + v_juros,
          capitalizado = true,
          capitalizado_em = now(),
          updated_at = now()
      WHERE id = v_rec.id;

      v_count := v_count + 1;
      v_total := v_total + v_juros;
    END IF;
  END LOOP;

  RETURN jsonb_build_object('emprestimos_capitalizados', v_count, 'juros_acrescentados', v_total);
END;
$$;

GRANT EXECUTE ON FUNCTION public.aplicar_capitalizacao_automatica(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.aplicar_capitalizacao_automatica(uuid) TO service_role;