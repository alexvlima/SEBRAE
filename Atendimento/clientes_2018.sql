SELECT 
	s.nomeabrev,
	h.CodCliente,
	paf.NomeRazaoSocial as 'Nome',
	paf.CgcCpf as 'CPF',
	h.CodEmpreedimento,
	-- paj.TipoParceiro as 'TipoParceiroEmpreendimento',
	pj.codconst as 'CodConstPJ',
	paj.CgcCpf as 'CNPJ',
	paj.NomeRazaoSocial as 'Razao_Social',
	paj.NomeAbrevFantasia as 'Nome_Fantasia',
	pj.faturam,
	-- paf.TipoParceiro AS 'TipoParceiroCliente',
	h.CodProjeto,
	-- h.CodConst AS codConstAtendimento,
	pj.CodProdutorRural,
	pj.CodPescador,
	pj.CodDap,
	-- MIN(h.MesAnoCompetencia) as 'MesAnoCompetenciaDoPrimeiroAtend', -- Função que retorna o mês em que o atendimento na nova constituição jurídica (quando mudar no decorrer do ano de análise). Para os atendimentos de 2013, o campo h.constJur sempre está NULL ou preenchido com '99' (= Empresa com CNPJ). Portanto, não há histórico de constituição jurídica em 2013.
	co.numero tel_res,
	cfp.numero celularPF,
	co2.numero tel_Comercial,
	cfp2.numero celularPJ,
	Publico = 
	 CASE WHEN
		(
		 h.codempreedimento is not null and h.codempreedimento <> 0
			and paj.cgccpf is not null and paj.cgccpf <> '0'
			and pj.codconst = 99 and pj.faturam in (2,3,99)
		) THEN 'Empresa'
		WHEN
		(
		 h.codempreedimento is not null and h.codempreedimento <> 0
			and ((pj.codprodutorrural is not null and pj.codprodutorrural <> '0') 
				or (pj.codpescador is not null and pj.codpescador <> '0') 
				or (pj.coddap is not null and pj.coddap <> '0') 
				or (pj.NIRF is not null and pj.NIRF <> '0')
				or (paj.cgccpf is not null and paj.cgccpf <> '0'))
			and pj.codconst = 12 and pj.faturam in (2,3,99)
		) THEN 'Prod Rural'
		WHEN
		(
		 h.codempreedimento is null or h.codempreedimento = 0
		) THEN 'PotEmpres/PotEmpree'
		WHEN
		(
		 h.codempreedimento is not null and h.codempreedimento <> 0
			and paj.cgccpf is not null and paj.cgccpf <> '0'
			and pj.codconst in (5,6) and pj.faturam = 3
		) THEN 'Assoc/Coop'
		ELSE 'Outro'
	 END
	/*--dados do atendimento
	CatAtendimento = at.Tipo -- instrumento de atendimento,
	MeioAtendimento = at.Situacao -- "meio" (presencial ou à distância),
	b.codrealizacao -- realização, categoria adicional que qualifica o instrumento,
	b.tiporealizacao -- realização, categoria adicional que qualifica o instrumento,
	ait.codtema temaait -- tema do atendimento, proveniente da tabela AREATEMATICA,
	ct.codtema temact -- tema do atendimento (quando o instrumento é consultoria),
	pp.CodFocoTematico -- foco temático (parecido com tema) do produto Sebrae ligado ao evento do atendimento. Nome proveniente da tabela FocoTematicoProdutoPortfolio,
	pp.CodFamiliaProduto -- família do produto Sebrae ligado ao evento do atendimento. Nome proveniente da tabela FamiliaProdutoPortfolio,
	ac.codprograma -- programa Sebrae do atendimento, se houver*/

FROM 
	dbo.sebrae s
	INNER JOIN	dbo.HistoricoRealizacoesCliente h ON s.codsebrae = h.CodSebrae
	-- Projeto
	INNER JOIN dbo.TBPAIPRATIF pratif ON h.CodProjeto = pratif.CodPRATIF
	-- Pessoa Fisica
	INNER JOIN dbo.Parceiro paf ON h.CodCliente = paf.CodParceiro
	INNER JOIN dbo.Pessoaf pf ON h.CodCliente = pf.CodParceiro
	-- Pessoa Juridica
	LEFT OUTER JOIN	dbo.Parceiro paj ON h.CodEmpreedimento = paj.CodParceiro
	LEFT OUTER JOIN dbo.Pessoaj	pj ON h.CodEmpreedimento = pj.codparceiro
	LEFT OUTER JOIN dbo.constjur coj ON pj.codconst = coj.CodConst
	-- Tipo de atendimento, para contabilização da Meta 1
	INNER JOIN categoriaAtendimento atend ON atend.descCategoria = h.instrumento COLLATE DATABASE_DEFAULT 
	/*--Endereço da pessoa jurídica
	LEFT OUTER JOIN dbo.Endereco ej ON h.CodEmpreedimento = ej.CodParceiro
	LEFT OUTER JOIN dbo.cidade cj ON ej.CodCid = cj.CodCid
	LEFT OUTER JOIN dbo.Estado ufj ON ej.CodEst = ufj.CodEst
	--Endereço da pessoa física
	LEFT OUTER JOIN dbo.Endereco ef ON h.CodCliente = ef.CodParceiro
	LEFT OUTER JOIN dbo.cidade cf ON ef.CodCid = cf.CodCid
	LEFT OUTER JOIN dbo.Estado uff ON ef.CodEst = uff.CodEst*/
	-- Telefone residencial da pessoa física
	left join (Select codparceiro, max(numseqcom) as numseqcom
						from comunicacao  
						where codcomunic = 1
						group by codparceiro) com
			on com.codparceiro = pf.codparceiro 
			left join comunicacao co 
			on (co.codparceiro = com.codparceiro
					and co.numseqcom = com.numseqcom 
					and co.codcomunic = 1)
	-- Telefone celular da pessoa física	
	left join (Select codparceiro ,max(numseqcom) as numseqcom 
					from comunicacao  
					where codcomunic = 5
					group by codparceiro) com2
			on com2.codparceiro = pf.codparceiro 
			left join comunicacao cfp 
			on (cfp.codparceiro = com2.codparceiro
					and cfp.numseqcom = com2.numseqcom 
					and cfp.codcomunic =5)
	-- Telefone comercial da pessoa jurídica
	left join (Select codparceiro, max(numseqcom) as numseqcom
					from comunicacao 
					where codcomunic = 6
					group by codparceiro) com3
			on com3.codparceiro = paj.codparceiro 
			left join comunicacao co2 
			on (co2.codparceiro = com3.codparceiro
					and co2.numseqcom = com3.numseqcom 
					and co2.codcomunic = 6 )
	-- Telefone celular da pessoa jurídica
	left join (Select codparceiro,max(numseqcom) as numseqcom
					from comunicacao 
					where codcomunic = 5
					group by codparceiro) com4
			on com4.codparceiro = paj.codparceiro 
			left join comunicacao cfp2
			on (cfp2.codparceiro = com4.codparceiro
					and cfp2.numseqcom = com4.numseqcom 
					and cfp2.codcomunic = 5 )
WHERE
	YEAR(h.MesAnoCompetencia) = 2018
	--Critérios adicionais de validação de atendimento
	AND paf.cgccpf is not null and paf.cgccpf <> '0'
	/* AND (atend.tipo in ('CO','CS','PA','IT','FP')
			or (atend.tipo = 'AE' and h.TipoRealizacao = 'MIS')
			or (atend.tipo = 'AE' and h.TipoRealizacao = 'FER')
			or (atend.tipo = 'PE' and h.TipoRealizacao = 'MIS')
			or (atend.tipo = 'PE' and h.TipoRealizacao = 'FER')
			or (atend.tipo = 'PE' and h.TipoRealizacao = 'ROD')				
		) */
	-- AND h.TipoRealizacao <> 'ATV'
	/*AND at.tipo in ('CO', 'CS', 'PA', 'PE', 'AE', 'IT', 'FP')
	AND h.tipoRealizacao &lt;&gt; 'ATV'*/
	-- AND h.codSebrae IN	(10,13,18,19,20,21,22,26,36)	-- NORDESTE
	-- AND h.codSebrae IN	(11,12,14,15,23,24,25,37)		-- NORTE E NACIONAL
	-- AND h.codSebrae IN	(33,31)							-- ES E RJ
	-- AND h.codSebrae IN	(16,17,34,35)					-- CENTRO-OESTE
	-- AND h.codSebrae =	32								-- MG
	-- AND h.codSebrae IN	(28,27,29)						-- SUL
	-- AND h.codSebrae =	30								-- SP

GROUP BY
	s.nomeabrev,
	h.CodCliente,
	paf.NomeRazaoSocial,
	paf.CgcCpf,
	h.CodEmpreedimento,
	--,paj.TipoParceiro,
	pj.codconst, 
	paj.CgcCpf, 
	paj.NomeRazaoSocial,
	paj.NomeAbrevFantasia,
	pj.faturam,
	-- paf.TipoParceiro, 
	h.CodProjeto,
	-- h.CodConst,
	pj.codprodutorrural,
	pj.codpescador,
	pj.coddap,
	-- MIN(h.MesAnoCompetencia),
	co.numero,
	cfp.numero,
	co2.numero,
	cfp2.numero,
	CASE WHEN
		(
		 h.codempreedimento is not null and h.codempreedimento <> 0
			and paj.cgccpf is not null and paj.cgccpf <> '0'
			and pj.codconst = 99 and pj.faturam in (2,3,99)
		) THEN 'Empresa'
		WHEN
		(
		 h.codempreedimento is not null and h.codempreedimento <> 0
			and ((pj.codprodutorrural is not null and pj.codprodutorrural <> '0') 
				or (pj.codpescador is not null and pj.codpescador <> '0') 
				or (pj.coddap is not null and pj.coddap <> '0') 
				or (pj.NIRF is not null and pj.NIRF <> '0')
				or (paj.cgccpf is not null and paj.cgccpf <> '0'))
			and pj.codconst = 12 and pj.faturam in (2,3,99)
		) THEN 'Prod Rural'
		WHEN
		(
		 h.codempreedimento is null or h.codempreedimento = 0
		) THEN 'PotEmpres/PotEmpree'
		WHEN
		(
		 h.codempreedimento is not null and h.codempreedimento <> 0
			and paj.cgccpf is not null and paj.cgccpf <> '0'
			and pj.codconst in (5,6) and pj.faturam = 3
		) THEN 'Assoc/Coop'
		ELSE 'Outro'
	 END
