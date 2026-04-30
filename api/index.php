<?php
define('AVALIA_SYSTEM', true);
define('BASE_PATH', dirname(__DIR__) . DIRECTORY_SEPARATOR);
require_once BASE_PATH . 'config/config.php';
require_once BASE_PATH . 'api/helpers/validator.php';
session_name(SESSION_NAME); session_start();
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); header('Access-Control-Allow-Headers: Content-Type, X-Requested-With'); header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
if ($_SERVER['REQUEST_METHOD']==='OPTIONS') exit;
function out($d,$c=200){if($c<400 && is_array($d) && (($d['ok']??false)===true) && in_array($_SERVER['REQUEST_METHOD']??'GET',['POST','PUT','PATCH','DELETE'],true)){logActivityAuto($d);} http_response_code($c);echo json_encode($d,JSON_UNESCAPED_UNICODE);exit;}
function body(){ $j=json_decode(file_get_contents('php://input'),true); return is_array($j)?$j:$_POST; }
function db(){ static $pdo; if(!$pdo){$pdo=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset='.DB_CHARSET,DB_USER,DB_PASS,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);} return $pdo; }
function rows($sql,$p=[]){$s=db()->prepare($sql);$s->execute($p);return $s->fetchAll();}
function row($sql,$p=[]){$r=rows($sql,$p);return $r[0]??null;}
function scalar($sql,$p=[]){$r=row($sql,$p);return $r?array_values($r)[0]:0;}
function me(){return $_SESSION['usuario']??null;}
function need(){if(!me())out(['ok'=>false,'error'=>'Não autenticado'],401);return me();}
function needAdmin(){ $u=need(); if(($u['nivel']??'')!=='admin') out(['ok'=>false,'error'=>'Apenas administrador pode acessar esta versão'],403); return $u; }
function roleId($nivel){$r=row('SELECT id FROM tipos_usuario WHERE LOWER(nome)=? LIMIT 1',[strtolower($nivel)]);return $r?(int)$r['id']:(['admin'=>1,'professor'=>2,'aluno'=>3,'moderador'=>4][strtolower($nivel)]??3);} 
function colExists($t,$c){try{$s=db()->prepare('SELECT COUNT(*) c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?');$s->execute([$t,$c]);return (int)$s->fetch()['c']>0;}catch(Throwable $e){return false;}}
function tableExists($t){try{$s=db()->prepare('SELECT COUNT(*) c FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?');$s->execute([$t]);return (int)$s->fetch()['c']>0;}catch(Throwable $e){return false;}}
function logActivityAuto($payload=[]){
	try{
		if(!tableExists('log_atividades')) return;
		foreach([
			'entidade'=>'VARCHAR(80) NULL',
			'entidade_id'=>'INT UNSIGNED NULL',
			'detalhes'=>'TEXT NULL',
			'ip'=>'VARCHAR(45) NULL',
			'user_agent'=>'VARCHAR(255) NULL'
		] as $c=>$def){
			if(!colExists('log_atividades',$c)){try{db()->exec("ALTER TABLE log_atividades ADD COLUMN `$c` $def");}catch(Throwable $e){}}
		}
		$u=me();
		$path=trim($_GET['path']??'','/');
		$method=$_SERVER['REQUEST_METHOD']??'GET';
		$parts=explode('/',$path);
		$entidade=$parts[0]?:'sistema';
		$acao=['POST'=>'criou','PUT'=>'editou','PATCH'=>'editou','DELETE'=>'excluiu'][$method]??strtolower($method);
		if($method==='POST' && preg_match('#/status$#',$path)) $acao='alterou status';
		if($path==='auth/login'){$acao='login';$entidade='autenticação';}
		if($path==='auth/logout'){$acao='logout';$entidade='autenticação';}
		$entidadeId=null;
		foreach($parts as $part){ if(ctype_digit((string)$part)){ $entidadeId=(int)$part; break; } }
		if(!$entidadeId && isset($payload['id'])) $entidadeId=(int)$payload['id'];
		$nomeEntidade=['usuarios'=>'usuário','escolas'=>'escola','turmas'=>'turma','disciplinas'=>'disciplina','avaliacoes'=>'avaliação','perfil'=>'perfil'][$entidade]??$entidade;
		$detalhes=trim(($acao.' '.$nomeEntidade).($entidadeId?' #'.$entidadeId:''));
		if($entidade==='avaliacoes' && $method==='POST' && $entidadeId) $detalhes='Criou avaliação/prova #'.$entidadeId;
		if($entidade==='avaliacoes' && $method==='PUT' && $entidadeId) $detalhes='Editou avaliação/prova #'.$entidadeId;
		if($entidade==='avaliacoes' && $method==='DELETE' && $entidadeId) $detalhes='Excluiu avaliação/prova #'.$entidadeId;
		$cols=['usuario_id','acao'];
		$vals=[$u['id']??null,$acao];
		if(colExists('log_atividades','entidade')){$cols[]='entidade';$vals[]=$nomeEntidade;}
		if(colExists('log_atividades','entidade_id')){$cols[]='entidade_id';$vals[]=$entidadeId;}
		if(colExists('log_atividades','detalhes')){$cols[]='detalhes';$vals[]=$detalhes;}
		elseif(colExists('log_atividades','descricao')){$cols[]='descricao';$vals[]=$detalhes;}
		if(colExists('log_atividades','ip')){$cols[]='ip';$vals[]=$_SERVER['REMOTE_ADDR']??'';}
		if(colExists('log_atividades','user_agent')){$cols[]='user_agent';$vals[]=substr($_SERVER['HTTP_USER_AGENT']??'',0,255);}
		$ph=implode(',',array_fill(0,count($cols),'?'));
		$sql='INSERT INTO log_atividades (`'.implode('`,`',$cols).'`) VALUES ('.$ph.')';
		db()->prepare($sql)->execute($vals);
	} catch(Throwable $e){}
}

function exigirDocumentoValido($valor,$tipo=''){
	$r=validarDocumentoInvertexto($valor,$tipo);
	if(!$r['ok']) out(['ok'=>false,'error'=>$r['message'],'validator'=>$r],422);
	return $r;
}
function ensureCols(){if(tableExists('questoes') && !colExists('questoes','tipo')){try{db()->exec("ALTER TABLE questoes ADD COLUMN `tipo` VARCHAR(20) NOT NULL DEFAULT 'objetiva' AFTER `enunciado`");}catch(Throwable $e){}} foreach(['cpf_cnpj'=>'VARCHAR(18) NULL','telefone'=>'VARCHAR(20) NULL','vlibras_ativo'=>'TINYINT(1) DEFAULT 1','alto_contraste'=>'TINYINT(1) DEFAULT 0','font_size'=>"VARCHAR(20) DEFAULT 'normal'",'avatar_cor'=>"VARCHAR(20) DEFAULT '#9333ea'",'avatar_imagem'=>'VARCHAR(255) NULL','tema'=>"VARCHAR(30) DEFAULT 'claro'"] as $c=>$def){if(!colExists('usuarios',$c)){try{db()->exec("ALTER TABLE usuarios ADD COLUMN `$c` $def");}catch(Throwable $e){}}}}
function deleteInactiveUser($usuarioId){
	$usuarioId=(int)$usuarioId;
	$u=row('SELECT u.id,u.usuario,u.ativo,LOWER(t.nome) nivel FROM usuarios u JOIN tipos_usuario t ON t.id=u.tipo_id WHERE u.id=?',[$usuarioId]);
	if(!$u) out(['ok'=>false,'error'=>'Usuário não encontrado.'],404);
	if(($u['nivel']??'')==='admin' || strtolower((string)($u['usuario']??''))==='admin') out(['ok'=>false,'error'=>'O usuário administrador não pode ser excluído. Ele pode apenas ser ativado/inativado.'],422);
	if((int)$u['ativo']===1) out(['ok'=>false,'error'=>'Só é possível excluir usuários inativos. Desative o usuário antes de excluir.'],422);
	if(me() && (int)me()['id']===$usuarioId) out(['ok'=>false,'error'=>'Você não pode excluir o próprio usuário logado.'],422);
	$pdo=db();
	try{
		$pdo->beginTransaction();
		$aluno=row('SELECT id FROM alunos WHERE usuario_id=?',[$usuarioId]);
		if($aluno){
			$alunoId=(int)$aluno['id'];
			if(tableExists('respostas')) $pdo->prepare('DELETE FROM respostas WHERE aluno_id=?')->execute([$alunoId]);
			if(tableExists('resultados')) $pdo->prepare('DELETE FROM resultados WHERE aluno_id=?')->execute([$alunoId]);
			if(tableExists('turmas_alunos')) $pdo->prepare('DELETE FROM turmas_alunos WHERE aluno_id=?')->execute([$alunoId]);
			$pdo->prepare('DELETE FROM alunos WHERE id=?')->execute([$alunoId]);
		}
		$prof=row('SELECT id FROM professores WHERE usuario_id=?',[$usuarioId]);
		if($prof){
			$profId=(int)$prof['id'];
			if(tableExists('avaliacoes')) $pdo->prepare('UPDATE avaliacoes SET professor_id=NULL WHERE professor_id=?')->execute([$profId]);
			if(tableExists('turmas')) $pdo->prepare('UPDATE turmas SET professor_id=NULL WHERE professor_id=?')->execute([$profId]);
			if(tableExists('disciplina_professor_turma')) $pdo->prepare('DELETE FROM disciplina_professor_turma WHERE professor_id=?')->execute([$profId]);
			$pdo->prepare('DELETE FROM professores WHERE id=?')->execute([$profId]);
		}
		if(tableExists('moderador_escola')) $pdo->prepare('DELETE FROM moderador_escola WHERE usuario_id=?')->execute([$usuarioId]);
		if(tableExists('log_atividades')) $pdo->prepare('DELETE FROM log_atividades WHERE usuario_id=?')->execute([$usuarioId]);
		if(tableExists('avaliacoes')) $pdo->prepare('UPDATE avaliacoes SET criado_por_usuario_id=NULL WHERE criado_por_usuario_id=?')->execute([$usuarioId]);
		$pdo->prepare('DELETE FROM usuarios WHERE id=?')->execute([$usuarioId]);
		$pdo->commit();
		out(['ok'=>true,'message'=>'Usuário excluído definitivamente.']);
	} catch(Throwable $e) {
		if($pdo->inTransaction()) $pdo->rollBack();
		out(['ok'=>false,'error'=>'Não foi possível excluir o usuário: '.$e->getMessage()],500);
	}
}
function userSession($u){return ['id'=>(int)$u['id'],'nome'=>$u['nome_completo'],'usuario'=>$u['usuario'],'nivel'=>strtolower($u['nivel']??'admin'),'email'=>$u['email']??'','telefone'=>$u['telefone']??'','tema'=>$u['tema']??'claro','avatar_cor'=>$u['avatar_cor']??'#9333ea','avatar_imagem'=>$u['avatar_imagem']??null,'vlibras_ativo'=>(int)($u['vlibras_ativo']??1),'alto_contraste'=>(int)($u['alto_contraste']??0),'font_size'=>$u['font_size']??'normal'];}
function salvarQuestoesAvaliacao($avaliacaoId,$questoes,$alternativasPorQuestao=5){
	$pdo=db();
	$avaliacaoId=(int)$avaliacaoId;
	if(!is_array($questoes)) $questoes=[];
	$ids=rows('SELECT id FROM questoes WHERE avaliacao_id=?',[$avaliacaoId]);
	foreach($ids as $q){ $pdo->prepare('DELETE FROM alternativas WHERE questao_id=?')->execute([(int)$q['id']]); }
	$pdo->prepare('DELETE FROM questoes WHERE avaliacao_id=?')->execute([$avaliacaoId]);
	$numero=1;
	$total=max(1,count($questoes));
	$valorAutomatico=round(10/$total,2);
	$temTipo=colExists('questoes','tipo');
	foreach($questoes as $q){
		if(!is_array($q)) continue;
		$tipo=strtolower(trim((string)($q['tipo']??'objetiva')))==='dissertativa'?'dissertativa':'objetiva';
		$enunciado=trim((string)($q['enunciado']??''));
		$gabarito=strtoupper(trim((string)($q['gabarito']??'')));
		if($tipo==='dissertativa') $gabarito=null;
		$valor=$valorAutomatico;
		if($enunciado==='') { $numero++; continue; }
		if($temTipo){
			$pdo->prepare('INSERT INTO questoes (avaliacao_id,numero,enunciado,tipo,gabarito,valor) VALUES (?,?,?,?,?,?)')->execute([$avaliacaoId,$numero,$enunciado,$tipo,$gabarito,$valor]);
		} else{
			$pdo->prepare('INSERT INTO questoes (avaliacao_id,numero,enunciado,gabarito,valor) VALUES (?,?,?,?,?)')->execute([$avaliacaoId,$numero,$enunciado,$gabarito,$valor]);
		}
	$questaoId=(int)$pdo->lastInsertId();
	if($tipo==='objetiva'){
		$alts=$q['alternativas']??[];
		if(!is_array($alts)) $alts=[];
		$letras=range('A','Z');
		$limite=max(count($alts), (int)$alternativasPorQuestao);
		for($i=0;$i<$limite && $i<26;$i++){
			$texto='';
			if(isset($alts[$i]) && is_array($alts[$i])) $texto=trim((string)($alts[$i]['texto']??''));
			elseif(isset($alts[$letras[$i]])) $texto=trim((string)$alts[$letras[$i]]);
			if($texto==='') continue;
			$pdo->prepare('INSERT INTO alternativas (questao_id,letra,texto) VALUES (?,?,?)')->execute([$questaoId,$letras[$i],$texto]);
			}
		}
		$numero++;
	}
}
function validarDadosAvaliacao($d){
	$titulo=trim((string)($d['titulo']??''));
	if($titulo==='') out(['ok'=>false,'error'=>'Informe o título da avaliação.'],422);
	if(empty($d['turma_id'])) out(['ok'=>false,'error'=>'Selecione a turma da avaliação.'],422);
	$data=trim((string)($d['data_prova']??''));
	if($data==='') out(['ok'=>false,'error'=>'Informe a data da avaliação.'],422);
	if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$data)) out(['ok'=>false,'error'=>'Informe uma data válida para a avaliação.'],422);
	if($data < date('Y-m-d')) out(['ok'=>false,'error'=>'A data da avaliação não pode ser anterior à data atual.'],422);
	$numeroQuestoes=max(0,(int)($d['numero_questoes']??0));
	if($numeroQuestoes<1) out(['ok'=>false,'error'=>'Informe pelo menos 1 questão.'],422);
	$questoes=$d['questoes']??[];
	if(!is_array($questoes) || count($questoes)!==$numeroQuestoes) out(['ok'=>false,'error'=>'A quantidade de questões não confere com os campos preenchidos.'],422);
	foreach($questoes as $i=>$q){
		if(!is_array($q)) out(['ok'=>false,'error'=>'Questão '.($i+1).' inválida.'],422);
		$tipo=strtolower(trim((string)($q['tipo']??'objetiva')))==='dissertativa'?'dissertativa':'objetiva';
		if(trim((string)($q['enunciado']??''))==='') out(['ok'=>false,'error'=>'Informe o enunciado da questão '.($i+1).'.'],422);
			if($tipo==='objetiva'){
			if(trim((string)($q['gabarito']??''))==='') out(['ok'=>false,'error'=>'Selecione o gabarito da questão '.($i+1).'.'],422);
			$alts=$q['alternativas']??[]; $preenchidas=0;
			if(is_array($alts)){ foreach($alts as $a){ if(is_array($a) && trim((string)($a['texto']??''))!=='') $preenchidas++; } }
			if($preenchidas<2) out(['ok'=>false,'error'=>'A questão '.($i+1).' precisa ter pelo menos 2 alternativas preenchidas.'],422);
		}
	}
	return [$numeroQuestoes,max(2,(int)($d['alternativas_por_questao']??5))];
}
$path=trim($_GET['path']??'','/'); $method=$_SERVER['REQUEST_METHOD'];
try{
	if($path==='auth/login'&&$method==='POST'){ensureCols();$d=body();$s=db()->prepare("SELECT u.*,LOWER(t.nome) nivel FROM usuarios u JOIN tipos_usuario t ON t.id=u.tipo_id WHERE u.usuario=? AND u.ativo=1 LIMIT 1");$s->execute([$d['usuario']??'']);$u=$s->fetch(); if(!$u||!password_verify($d['senha']??'',$u['senha_hash'])) out(['ok'=>false,'error'=>'Usuário ou senha inválidos'],401); if(strtolower($u['nivel'])!=='admin') out(['ok'=>false,'error'=>'Esta versão permite login apenas de administrador.'],403); $_SESSION['usuario']=userSession($u); out(['ok'=>true,'user'=>$_SESSION['usuario']]);}
	if($path==='auth/logout'){session_destroy();out(['ok'=>true]);}
	if($path==='me'){ensureCols();$u=me(); if($u){$r=row("SELECT u.*,LOWER(t.nome) nivel FROM usuarios u JOIN tipos_usuario t ON t.id=u.tipo_id WHERE u.id=?",[$u['id']]); if($r){$_SESSION['usuario']=userSession($r);$u=$_SESSION['usuario'];}} out(['ok'=>true,'user'=>$u]);}
	needAdmin();

	if($path==='logs'&&$method==='GET'){ $limit=max(1,min(200,(int)($_GET['limit']??50))); out(['ok'=>true,'items'=>rows("SELECT l.*,u.nome_completo usuario_nome,u.usuario FROM log_atividades l LEFT JOIN usuarios u ON u.id=l.usuario_id ORDER BY l.id DESC LIMIT $limit")]);}

	if($path==='integracoes/cep'&&$method==='GET'){
		$cep=onlyDigits($_GET['cep']??'');
		if(strlen($cep)!==8) out(['ok'=>false,'error'=>'CEP inválido'],422);
		$url='https://viacep.com.br/ws/'.$cep.'/json/';
		$ctx=stream_context_create(['http'=>['timeout'=>8,'ignore_errors'=>true,'header'=>'User-Agent: Avalia/1.0\r\n']]);
		$raw=@file_get_contents($url,false,$ctx);
		if(!$raw) out(['ok'=>false,'error'=>'Não foi possível consultar o ViaCEP.'],502);
		$data=json_decode($raw,true);
		if(!$data||!empty($data['erro'])) out(['ok'=>false,'error'=>'CEP não encontrado.'],404);
		out(['ok'=>true,'data'=>[
			'cep'=>$data['cep']??$cep,
			'logradouro'=>$data['logradouro']??'',
			'bairro'=>$data['bairro']??'',
			'cidade'=>$data['localidade']??'',
			'uf'=>$data['uf']??'',
			'complemento'=>$data['complemento']??'',
			'endereco'=>trim(($data['logradouro']??'').', '.($data['bairro']??'').' - '.($data['localidade']??'').'/'.($data['uf']??''),' ,-')
		]]);
	}
	if($path==='integracoes/validator'&&$method==='GET'){
		$value=$_GET['value']??'';
		$type=$_GET['type']??'';
		$r=validarDocumentoInvertexto($value,$type);
		out(['ok'=>$r['ok'],'valid'=>$r['ok'],'api'=>$r['api']??false,'message'=>$r['message']??'', 'data'=>$r['data']??null], $r['ok']?200:422);
	}
	if($path==='integracoes/cnpj'&&$method==='GET'){
		$cnpj=onlyDigits($_GET['cnpj']??'');
		if(strlen($cnpj)!==14||!cnpjValido($cnpj)) out(['ok'=>false,'error'=>'CNPJ inválido'],422);
		$url='https://brasilapi.com.br/api/cnpj/v1/'.$cnpj;
		$ctx=stream_context_create(['http'=>['timeout'=>10,'ignore_errors'=>true,'header'=>'User-Agent: Avalia/1.0\r\n']]);
		$raw=@file_get_contents($url,false,$ctx);
		if(!$raw) out(['ok'=>false,'error'=>'Não foi possível consultar a BrasilAPI.'],502);
		$data=json_decode($raw,true);
		if(!$data||isset($data['message'])) out(['ok'=>false,'error'=>$data['message']??'CNPJ não encontrado.'],404);
		$end=trim(($data['descricao_tipo_de_logradouro']??'').' '.($data['logradouro']??'').', '.($data['numero']??'').' - '.($data['bairro']??'').' - '.($data['municipio']??'').'/'.($data['uf']??''),' ,-');
		out(['ok'=>true,'data'=>[
			'cnpj'=>$data['cnpj']??$cnpj,
			'nome'=>$data['razao_social']??'',
			'nome_fantasia'=>$data['nome_fantasia']??'',
			'email'=>$data['email']??'',
			'telefone'=>$data['ddd_telefone_1']??'',
			'cep'=>$data['cep']??'',
			'endereco'=>$end,
			'cidade'=>$data['municipio']??'',
			'uf'=>$data['uf']??''
		]]);
	}

function ensureAvaliacaoAtivo(){
	if(tableExists('avaliacoes') && !colExists('avaliacoes','ativo')){
		try{ db()->exec("ALTER TABLE avaliacoes ADD COLUMN ativo TINYINT(1) NOT NULL DEFAULT 1 AFTER status"); }catch(Throwable $e){}
	}
}
if($path==='dashboard'){ensureAvaliacaoAtivo();out(['ok'=>true,'counts'=>['escolas'=>scalar('SELECT COUNT(*) FROM escolas'),'usuarios'=>scalar('SELECT COUNT(*) FROM usuarios'),'professores'=>scalar('SELECT COUNT(*) FROM professores'),'alunos'=>scalar('SELECT COUNT(*) FROM alunos'),'moderadores'=>scalar('SELECT COUNT(*) FROM usuarios WHERE tipo_id=?',[roleId('moderador')]),'turmas'=>scalar('SELECT COUNT(*) FROM turmas'),'disciplinas'=>scalar('SELECT COUNT(*) FROM disciplinas'),'avaliacoes'=>scalar('SELECT COUNT(*) FROM avaliacoes'),'pendentes'=>scalar("SELECT COUNT(*) FROM avaliacoes WHERE status<>'concluida'")],'ultimas'=>rows("SELECT a.id,a.titulo,a.status,COALESCE(a.ativo,1) ativo,a.data_prova,t.nome turma,d.nome disciplina,e.nome escola FROM avaliacoes a LEFT JOIN turmas t ON t.id=a.turma_id LEFT JOIN disciplinas d ON d.id=a.disciplina_id LEFT JOIN escolas e ON e.id=t.escola_id ORDER BY a.id DESC LIMIT 8")]);}
	if($path==='lookups'){out(['ok'=>true,'escolas'=>rows('SELECT id,nome FROM escolas ORDER BY nome'),'turmas'=>rows('SELECT t.id,t.nome,e.nome escola FROM turmas t LEFT JOIN escolas e ON e.id=t.escola_id ORDER BY e.nome,t.nome'),'disciplinas'=>rows('SELECT id,nome FROM disciplinas ORDER BY nome'),'professores'=>rows("SELECT p.id,u.nome_completo nome FROM professores p JOIN usuarios u ON u.id=p.usuario_id WHERE u.ativo=1 ORDER BY u.nome_completo"),'tipos'=>rows('SELECT id,nome FROM tipos_usuario ORDER BY id')]);}
	if($path==='usuarios'&&$method==='GET'){ $cpf=colExists('usuarios','cpf_cnpj')?'COALESCE(u.cpf_cnpj,u.cpf,al.cpf,p.cpf)':'COALESCE(u.cpf,al.cpf,p.cpf)'; out(['ok'=>true,'items'=>rows("SELECT u.id,u.nome_completo,u.usuario,u.email,u.telefone,u.ativo,$cpf cpf_cnpj,LOWER(tu.nome) nivel,al.matricula,COALESCE(te.nome,ea.nome) turma_nome,COALESCE(ee.nome,eal.nome) escola_nome FROM usuarios u JOIN tipos_usuario tu ON tu.id=u.tipo_id LEFT JOIN alunos al ON al.usuario_id=u.id LEFT JOIN professores p ON p.usuario_id=u.id LEFT JOIN turmas_alunos ta ON ta.aluno_id=al.id AND ta.ativo=1 LEFT JOIN turmas te ON te.id=ta.turma_id LEFT JOIN escolas ee ON ee.id=te.escola_id LEFT JOIN escolas eal ON eal.id=al.escola_id LEFT JOIN turmas ea ON 1=0 ORDER BY tu.id, escola_nome, turma_nome, u.nome_completo")]);}
	if(preg_match('#^usuarios/(\d+)$#',$path,$m)&&$method==='GET'){ $cpf=colExists('usuarios','cpf_cnpj')?'COALESCE(u.cpf_cnpj,u.cpf,al.cpf,p.cpf)':'COALESCE(u.cpf,al.cpf,p.cpf)'; $item=row("SELECT u.id,u.nome_completo,u.usuario,u.email,u.telefone,u.ativo,$cpf cpf_cnpj,LOWER(tu.nome) nivel,al.matricula,al.escola_id,p.instituicao,ta.turma_id FROM usuarios u JOIN tipos_usuario tu ON tu.id=u.tipo_id LEFT JOIN alunos al ON al.usuario_id=u.id LEFT JOIN professores p ON p.usuario_id=u.id LEFT JOIN turmas_alunos ta ON ta.aluno_id=al.id AND ta.ativo=1 WHERE u.id=?",[(int)$m[1]]); if(!$item)out(['ok'=>false,'error'=>'Usuário não encontrado'],404); out(['ok'=>true,'item'=>$item]);}
	if($path==='usuarios'&&$method==='POST'){ensureCols();$d=body(); exigirDocumentoValido($d['cpf_cnpj']??'', (($d['nivel']??'')==='aluno'?'cpf':'')); if(strlen($d['senha']??'')<6)out(['ok'=>false,'error'=>'Senha deve ter no mínimo 6 caracteres'],422); $tipo=roleId($d['nivel']??'aluno'); db()->prepare('INSERT INTO usuarios (nome_completo,usuario,cpf_cnpj,cpf,senha_hash,tipo_id,email,telefone,ativo,tema,avatar_cor,vlibras_ativo) VALUES (?,?,?,?,?,?,?,?,1,\'claro\',\'#9333ea\',1)')->execute([$d['nome_completo'],$d['usuario'],$d['cpf_cnpj']??null,$d['cpf_cnpj']??null,password_hash($d['senha'],PASSWORD_DEFAULT),$tipo,$d['email']??null,$d['telefone']??null]); $uid=(int)db()->lastInsertId(); if(($d['nivel']??'')==='aluno')db()->prepare('INSERT INTO alunos (usuario_id,nome_completo,matricula,cpf,email,celular,ano_letivo,escola_id) VALUES (?,?,?,?,?,?,?,?)')->execute([$uid,$d['nome_completo'],$d['matricula']?:('ALU'.date('Y').$uid),$d['cpf_cnpj']??null,$d['email']??null,$d['telefone']??null,date('Y'),$d['escola_id']?:null]); if(($d['nivel']??'')==='professor')db()->prepare('INSERT INTO professores (usuario_id,cpf,celular,instituicao,cargo) VALUES (?,?,?,?,?)')->execute([$uid,$d['cpf_cnpj']??null,$d['telefone']??null,$d['instituicao']??null,'Professor']); out(['ok'=>true]);}
	if(preg_match('#^usuarios/(\d+)$#',$path,$m)&&$method==='PUT'){ $d=body(); exigirDocumentoValido($d['cpf_cnpj']??'', (($d['nivel']??'')==='aluno'?'cpf':'')); $fields='nome_completo=?,usuario=?,cpf_cnpj=?,cpf=?,email=?,telefone=?,tipo_id=?'; $params=[$d['nome_completo'],$d['usuario'],$d['cpf_cnpj']??null,$d['cpf_cnpj']??null,$d['email']??null,$d['telefone']??null,roleId($d['nivel']??'aluno')]; if(!empty($d['senha'])){if(strlen($d['senha'])<6)out(['ok'=>false,'error'=>'Senha deve ter no mínimo 6 caracteres'],422);$fields.=',senha_hash=?';$params[]=password_hash($d['senha'],PASSWORD_DEFAULT);} $params[]=(int)$m[1]; db()->prepare("UPDATE usuarios SET $fields WHERE id=?")->execute($params); out(['ok'=>true]);}
	if(preg_match('#^usuarios/(\d+)/status$#',$path,$m)&&$method==='POST'){ $d=body(); db()->prepare('UPDATE usuarios SET ativo=? WHERE id=?')->execute([(int)($d['ativo']??1),(int)$m[1]]); out(['ok'=>true]);}
	if(preg_match('#^usuarios/(\d+)$#',$path,$m)&&$method==='DELETE'){deleteInactiveUser((int)$m[1]);}
	if($path==='escolas'&&$method==='GET')out(['ok'=>true,'items'=>rows('SELECT e.*,(SELECT COUNT(*) FROM turmas t WHERE t.escola_id=e.id) turmas,(SELECT COUNT(*) FROM alunos a WHERE a.escola_id=e.id) alunos FROM escolas e ORDER BY e.nome')]);
	if(preg_match('#^escolas/(\d+)$#',$path,$m)&&$method==='GET'){ $item=row('SELECT * FROM escolas WHERE id=?',[(int)$m[1]]); if(!$item)out(['ok'=>false,'error'=>'Escola não encontrada'],404); out(['ok'=>true,'item'=>$item]);}
	if($path==='escolas'&&$method==='POST'){ $d=body(); if(($d['cnpj']??'')) exigirDocumentoValido($d['cnpj'],'cnpj'); db()->prepare('INSERT INTO escolas (nome,cnpj,endereco,telefone,email,ativo) VALUES (?,?,?,?,?,1)')->execute([$d['nome'],$d['cnpj']??null,$d['endereco']??null,$d['telefone']??null,$d['email']??null]); out(['ok'=>true]);}
	if(preg_match('#^escolas/(\d+)$#',$path,$m)&&$method==='PUT'){ $d=body(); if(($d['cnpj']??'')) exigirDocumentoValido($d['cnpj'],'cnpj'); db()->prepare('UPDATE escolas SET nome=?,cnpj=?,endereco=?,telefone=?,email=?,ativo=? WHERE id=?')->execute([$d['nome'],$d['cnpj']??null,$d['endereco']??null,$d['telefone']??null,$d['email']??null,(int)($d['ativo']??1),(int)$m[1]]); out(['ok'=>true]);}
	if(preg_match('#^escolas/(\d+)/status$#',$path,$m)&&$method==='POST'){ $d=body(); db()->prepare('UPDATE escolas SET ativo=? WHERE id=?')->execute([(int)($d['ativo']??1),(int)$m[1]]); out(['ok'=>true]);}
	if(preg_match('#^escolas/(\d+)$#',$path,$m)&&$method==='DELETE'){ $it=row('SELECT ativo FROM escolas WHERE id=?',[(int)$m[1]]); if(!$it)out(['ok'=>false,'error'=>'Escola não encontrada.'],404); if((int)$it['ativo']===1)out(['ok'=>false,'error'=>'Desative a escola antes de excluir.'],422); try{db()->prepare('DELETE FROM escolas WHERE id=?')->execute([(int)$m[1]]);out(['ok'=>true]);}catch(Throwable $e){out(['ok'=>false,'error'=>'Não foi possível excluir a escola. Verifique turmas/alunos vinculados.'],422);}}
	if($path==='disciplinas'&&$method==='GET')out(['ok'=>true,'items'=>rows('SELECT * FROM disciplinas ORDER BY nome')]);
	if(preg_match('#^disciplinas/(\d+)$#',$path,$m)&&$method==='GET'){ $item=row('SELECT * FROM disciplinas WHERE id=?',[(int)$m[1]]); if(!$item)out(['ok'=>false,'error'=>'Disciplina não encontrada'],404); out(['ok'=>true,'item'=>$item]);}
	if($path==='disciplinas'&&$method==='POST'){ $d=body(); db()->prepare('INSERT INTO disciplinas (nome,codigo,descricao,ativo) VALUES (?,?,?,1)')->execute([$d['nome'],$d['codigo']??null,$d['descricao']??null]); out(['ok'=>true]);}
	if(preg_match('#^disciplinas/(\d+)$#',$path,$m)&&$method==='PUT'){ $d=body(); db()->prepare('UPDATE disciplinas SET nome=?,codigo=?,descricao=?,ativo=? WHERE id=?')->execute([$d['nome'],$d['codigo']??null,$d['descricao']??null,(int)($d['ativo']??1),(int)$m[1]]); out(['ok'=>true]);}
	if(preg_match('#^disciplinas/(\d+)/status$#',$path,$m)&&$method==='POST'){ $d=body(); $ativo=(int)($d['ativo']??1); db()->prepare('UPDATE disciplinas SET ativo=? WHERE id=?')->execute([$ativo,(int)$m[1]]); out(['ok'=>true,'id'=>(int)$m[1],'ativo'=>$ativo]);}
	if(preg_match('#^disciplinas/(\d+)$#',$path,$m)&&$method==='DELETE'){ $it=row('SELECT ativo FROM disciplinas WHERE id=?',[(int)$m[1]]); if(!$it)out(['ok'=>false,'error'=>'Disciplina não encontrada.'],404); if((int)$it['ativo']===1)out(['ok'=>false,'error'=>'Desative a disciplina antes de excluir.'],422); try{db()->prepare('DELETE FROM disciplinas WHERE id=?')->execute([(int)$m[1]]);out(['ok'=>true]);}catch(Throwable $e){out(['ok'=>false,'error'=>'Não foi possível excluir a disciplina. Verifique avaliações vinculadas.'],422);}}
	if($path==='turmas'&&$method==='GET')out(['ok'=>true,'items'=>rows("SELECT t.*,e.nome escola_nome,up.nome_completo professor_nome,(SELECT COUNT(*) FROM turmas_alunos ta WHERE ta.turma_id=t.id AND ta.ativo=1) alunos_count,(SELECT COUNT(*) FROM disciplina_professor_turma dpt WHERE dpt.turma_id=t.id AND dpt.ativo=1) professores_count FROM turmas t LEFT JOIN escolas e ON e.id=t.escola_id LEFT JOIN professores p ON p.id=t.professor_id LEFT JOIN usuarios up ON up.id=p.usuario_id ORDER BY e.nome,t.nome")]);
	if(preg_match('#^turmas/(\d+)$#',$path,$m)&&$method==='GET'){ $item=row('SELECT * FROM turmas WHERE id=?',[(int)$m[1]]); if(!$item)out(['ok'=>false,'error'=>'Turma não encontrada'],404); out(['ok'=>true,'item'=>$item]);}
	if($path==='turmas'&&$method==='POST'){ $d=body(); $escolaId=(int)($d['escola_id']??0); if($escolaId<=0)out(['ok'=>false,'error'=>'A turma deve ser vinculada a uma escola para ser cadastrada.'],422); $escola=row('SELECT id, ativo FROM escolas WHERE id=?',[$escolaId]); if(!$escola)out(['ok'=>false,'error'=>'Escola não encontrada. Selecione uma escola válida para vincular a turma.'],422); if(isset($escola['ativo'])&&(int)$escola['ativo']!==1)out(['ok'=>false,'error'=>'A escola vinculada está inativa. Selecione uma escola ativa para cadastrar a turma.'],422); db()->prepare('INSERT INTO turmas (nome,serie_ano,turno,ano_letivo,capacidade_maxima,professor_id,sala,ativo,escola_id) VALUES (?,?,?,?,?,?,?,?,?)')->execute([$d['nome'],$d['serie_ano']??null,$d['turno']??null,$d['ano_letivo']??date('Y'),$d['capacidade_maxima']?:null,$d['professor_id']?:null,$d['sala']??null,1,$escolaId]); out(['ok'=>true]);}
	if(preg_match('#^turmas/(\d+)$#',$path,$m)&&$method==='PUT'){ $d=body(); $escolaId=(int)($d['escola_id']??0); if($escolaId<=0)out(['ok'=>false,'error'=>'A turma deve ser vinculada a uma escola para ser salva.'],422); $escola=row('SELECT id, ativo FROM escolas WHERE id=?',[$escolaId]); if(!$escola)out(['ok'=>false,'error'=>'Escola não encontrada. Selecione uma escola válida para vincular a turma.'],422); if(isset($escola['ativo'])&&(int)$escola['ativo']!==1)out(['ok'=>false,'error'=>'A escola vinculada está inativa. Selecione uma escola ativa para salvar a turma.'],422); db()->prepare('UPDATE turmas SET nome=?,serie_ano=?,turno=?,ano_letivo=?,capacidade_maxima=?,professor_id=?,sala=?,ativo=?,escola_id=? WHERE id=?')->execute([$d['nome'],$d['serie_ano']??null,$d['turno']??null,$d['ano_letivo']??date('Y'),$d['capacidade_maxima']?:null,$d['professor_id']?:null,$d['sala']??null,(int)($d['ativo']??1),$escolaId,(int)$m[1]]); out(['ok'=>true]);}
	if(preg_match('#^turmas/(\d+)/status$#',$path,$m)&&$method==='POST'){ $d=body(); $ativo=(int)($d['ativo']??1); db()->prepare('UPDATE turmas SET ativo=? WHERE id=?')->execute([$ativo,(int)$m[1]]); out(['ok'=>true,'id'=>(int)$m[1],'ativo'=>$ativo]);}
	if(preg_match('#^turmas/(\d+)$#',$path,$m)&&$method==='DELETE'){ $it=row('SELECT ativo FROM turmas WHERE id=?',[(int)$m[1]]); if(!$it)out(['ok'=>false,'error'=>'Turma não encontrada.'],404); if((int)$it['ativo']===1)out(['ok'=>false,'error'=>'Desative a turma antes de excluir.'],422); try{db()->prepare('DELETE FROM turmas WHERE id=?')->execute([(int)$m[1]]);out(['ok'=>true]);}catch(Throwable $e){out(['ok'=>false,'error'=>'Não foi possível excluir a turma. Verifique alunos/avaliações vinculados.'],422);}}
	if(preg_match('#^turmas/(\d+)/alunos$#',$path,$m))out(['ok'=>true,'items'=>rows("SELECT al.id,al.nome_completo,al.matricula,u.usuario,u.email,u.ativo FROM turmas_alunos ta JOIN alunos al ON al.id=ta.aluno_id JOIN usuarios u ON u.id=al.usuario_id WHERE ta.turma_id=? ORDER BY al.nome_completo",[(int)$m[1]])]);
	if($path==='avaliacoes'&&$method==='GET'){ensureAvaliacaoAtivo();out(['ok'=>true,'items'=>rows("SELECT a.id,a.titulo,a.data_prova,a.status,COALESCE(a.ativo,1) ativo,a.numero_questoes,a.peso,a.observacoes,t.nome turma,d.nome disciplina,e.nome escola,up.nome_completo professor FROM avaliacoes a LEFT JOIN turmas t ON t.id=a.turma_id LEFT JOIN escolas e ON e.id=t.escola_id LEFT JOIN disciplinas d ON d.id=a.disciplina_id LEFT JOIN professores p ON p.id=a.professor_id LEFT JOIN usuarios up ON up.id=p.usuario_id ORDER BY e.nome,t.nome,d.nome,a.data_prova DESC")]);}
	if($path==='avaliacoes'&&$method==='POST'){
		ensureAvaliacaoAtivo();
		$d=body();
		$pdo=db();
		try{
			$pdo->beginTransaction();
			[$numeroQuestoes,$altPorQuestao]=validarDadosAvaliacao($d);
			$stmt=$pdo->prepare('INSERT INTO avaliacoes (titulo,turma_id,disciplina_id,professor_id,data_prova,peso,numero_questoes,alternativas_por_questao,observacoes,status,ativo,criado_por_usuario_id) VALUES (?,?,?,?,?,?,?,?,?,?,1,?)');
			$stmt->execute([$d['titulo']??'', $d['turma_id']??null, ($d['disciplina_id']??'')?:null, ($d['professor_id']??'')?:null, ($d['data_prova']??'')?:null, ($d['peso']??1)?:1, $numeroQuestoes, $altPorQuestao, $d['observacoes']??null, $d['status']??'pendente', me()['id']]);
			$avaliacaoId=(int)$pdo->lastInsertId();
			salvarQuestoesAvaliacao($avaliacaoId,$d['questoes']??[],$altPorQuestao);
			$pdo->commit();
			out(['ok'=>true,'id'=>$avaliacaoId]);
		} catch(Throwable $e){ if($pdo->inTransaction())$pdo->rollBack(); throw $e; }
	}
	
	if(preg_match('#^avaliacoes/(\d+)$#',$path,$m)&&$method==='PUT'){
		ensureAvaliacaoAtivo();
		$d=body();
		$pdo=db();
		try{
			$pdo->beginTransaction();
			$avaliacaoId=(int)$m[1];
			[$numeroQuestoes,$altPorQuestao]=validarDadosAvaliacao($d);
			$pdo->prepare('UPDATE avaliacoes SET titulo=?,turma_id=?,disciplina_id=?,professor_id=?,data_prova=?,peso=?,numero_questoes=?,alternativas_por_questao=?,observacoes=?,status=? WHERE id=?')->execute([$d['titulo']??'', $d['turma_id']??null, ($d['disciplina_id']??'')?:null, ($d['professor_id']??'')?:null, ($d['data_prova']??'')?:null, ($d['peso']??1)?:1, $numeroQuestoes, $altPorQuestao, $d['observacoes']??null, $d['status']??'pendente', $avaliacaoId]);
			salvarQuestoesAvaliacao($avaliacaoId,$d['questoes']??[],$altPorQuestao);
			$pdo->commit();
			out(['ok'=>true]);
		}catch(Throwable $e){ if($pdo->inTransaction())$pdo->rollBack(); throw $e; }
	}
	if(preg_match('#^avaliacoes/(\d+)$#',$path,$m)&&$method==='GET'){ ensureAvaliacaoAtivo(); $id=(int)$m[1]; $a=row("SELECT a.*,COALESCE(a.ativo,1) ativo,t.nome turma,d.nome disciplina,e.nome escola,up.nome_completo professor FROM avaliacoes a LEFT JOIN turmas t ON t.id=a.turma_id LEFT JOIN escolas e ON e.id=t.escola_id LEFT JOIN disciplinas d ON d.id=a.disciplina_id LEFT JOIN professores p ON p.id=a.professor_id LEFT JOIN usuarios up ON up.id=p.usuario_id WHERE a.id=?",[$id]); if(!$a)out(['ok'=>false,'error'=>'Avaliação não encontrada'],404); $q=rows('SELECT * FROM questoes WHERE avaliacao_id=? ORDER BY numero,id',[$id]); foreach($q as &$qq){$qq['alternativas']=rows('SELECT letra,texto FROM alternativas WHERE questao_id=? ORDER BY letra',[$qq['id']]);} $res=rows('SELECT r.*,al.nome_completo aluno_nome,al.matricula FROM resultados r JOIN alunos al ON al.id=r.aluno_id WHERE r.avaliacao_id=? ORDER BY al.nome_completo',[$id]); out(['ok'=>true,'avaliacao'=>$a,'questoes'=>$q,'resultados'=>$res]);}
	if(preg_match('#^avaliacoes/(\d+)/status$#',$path,$m)&&$method==='POST'){
		ensureAvaliacaoAtivo();
		$d=body();
		$id=(int)$m[1];
		$atual=row('SELECT id,status,ativo FROM avaliacoes WHERE id=?',[$id]);
		if(!$atual) out(['ok'=>false,'error'=>'Avaliação não encontrada.'],404);
		if(array_key_exists('ativo',$d) || (($d['status']??'')==='toggle_ativo') || (($d['status']??'')==='toggle')){
			$novo = array_key_exists('ativo',$d) ? (int)$d['ativo'] : (((int)($atual['ativo']??1)===1) ? 0 : 1);
			db()->prepare('UPDATE avaliacoes SET ativo=? WHERE id=?')->execute([$novo,$id]);
			out(['ok'=>true,'id'=>$id,'status'=>$atual['status'],'ativo'=>$novo]);
		}
		$status=$d['status']??'pendente';
		$permitidos=['pendente','em_andamento','correcao_pendente','concluida'];
		if(!in_array($status,$permitidos,true)) out(['ok'=>false,'error'=>'Status de avaliação inválido.'],422);
		db()->prepare('UPDATE avaliacoes SET status=? WHERE id=?')->execute([$status,$id]);
		out(['ok'=>true,'id'=>$id,'status'=>$status,'ativo'=>(int)($atual['ativo']??1)]);
		} if(preg_match('#^avaliacoes/(\d+)$#',$path,$m)&&$method==='DELETE'){
		ensureAvaliacaoAtivo();
		$id=(int)$m[1];
		$it=row('SELECT ativo FROM avaliacoes WHERE id=?',[$id]);
		if(!$it)out(['ok'=>false,'error'=>'Avaliação não encontrada.'],404);
		if((int)($it['ativo']??1)===1)out(['ok'=>false,'error'=>'Inative a avaliação antes de excluir.'],422);
		$pdo=db();
		try{
			$pdo->beginTransaction();
			if(tableExists('alternativas')) $pdo->prepare('DELETE alt FROM alternativas alt JOIN questoes q ON q.id=alt.questao_id WHERE q.avaliacao_id=?')->execute([$id]);
			if(tableExists('questoes')) $pdo->prepare('DELETE FROM questoes WHERE avaliacao_id=?')->execute([$id]);
			if(tableExists('resultados')) $pdo->prepare('DELETE FROM resultados WHERE avaliacao_id=?')->execute([$id]);
			$pdo->prepare('DELETE FROM avaliacoes WHERE id=?')->execute([$id]);
			$pdo->commit();
			out(['ok'=>true]);
		}catch(Throwable $e){
			if($pdo->inTransaction()) $pdo->rollBack();
			out(['ok'=>false,'error'=>'Não foi possível excluir a avaliação: '.$e->getMessage()],422);
		}
	}
	if($path==='perfil'&&$method==='GET'){out(['ok'=>true,'user'=>me()]);}
	if($path==='perfil'&&$method==='POST'){ensureCols();$u=me();$d=body();db()->prepare('UPDATE usuarios SET nome_completo=?,email=?,telefone=?,tema=?,avatar_cor=?,vlibras_ativo=?,alto_contraste=?,font_size=? WHERE id=?')->execute([$d['nome']??$u['nome'],$d['email']??$u['email'],$d['telefone']??$u['telefone'],$d['tema']??'claro',$d['avatar_cor']??'#9333ea',(int)($d['vlibras_ativo']??0),(int)($d['alto_contraste']??0),$d['font_size']??'normal',$u['id']]); $r=row("SELECT u.*,LOWER(t.nome) nivel FROM usuarios u JOIN tipos_usuario t ON t.id=u.tipo_id WHERE u.id=?",[$u['id']]); $_SESSION['usuario']=userSession($r); out(['ok'=>true,'user'=>$_SESSION['usuario']]);}
	if($path==='perfil/senha'&&$method==='POST'){ $u=me();$d=body(); if(strlen($d['nova_senha']??'')<6)out(['ok'=>false,'error'=>'A nova senha deve ter no mínimo 6 caracteres'],422); if(($d['nova_senha']??'')!==($d['confirmar_senha']??''))out(['ok'=>false,'error'=>'As senhas não conferem'],422); $hash=scalar('SELECT senha_hash FROM usuarios WHERE id=?',[$u['id']]); if(!password_verify($d['senha_atual']??'',$hash))out(['ok'=>false,'error'=>'Senha atual incorreta'],422); db()->prepare('UPDATE usuarios SET senha_hash=? WHERE id=?')->execute([password_hash($d['nova_senha'],PASSWORD_DEFAULT),$u['id']]); out(['ok'=>true]);}
	out(['ok'=>false,'error'=>'Rota não encontrada','path'=>$path],404);
} catch(Throwable $e){out(['ok'=>false,'error'=>APP_ENV==='local'?$e->getMessage():'Erro interno'],500);} 
