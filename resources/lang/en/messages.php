<?php

return [

    'lang' => 'Português',

    'date' => [
        'default' => 'j \de F \de Y',
        'full' => 'j \de F \de Y \às G:i',
        'compact' => 'd/m/Y \às G:i',
    ],

    'nav' => [
        'toggle' => 'Alternar navegação',
        'profile' => 'Perfil',
        'admin' => 'Painel de administração',
    ],

    'actions' => [
        'add' => 'Adicionar',
        'back' => 'Voltar',
        'browse' => 'Navegar',
        'cancel' => 'Cancelar',
        'choose_file' => 'Escolher arquivo',
        'close' => 'Fechar',
        'collapse' => 'Recolher',
        'comment' => 'Comentar',
        'continue' => 'Continuar',
        'copy' => 'Copiar',
        'create' => 'Criar',
        'delete' => 'Excluir',
        'disable' => 'Desativar',
        'download' => 'Download',
        'duplicate' => 'Duplicar',
        'edit' => 'Editar',
        'enable' => 'Habilitar',
        'expand' => 'Expandir',
        'generate' => 'Gerar',
        'install' => 'Instalar',
        'move' => 'Mover',
        'refresh' => 'Atualizar',
        'reload' => 'Recarregar',
        'remove' => 'Remover',
        'save' => 'Salvar',
        'search' => 'Pesquisar',
        'send' => 'Enviar',
        'show' => 'Mostrar',
        'sort' => 'Ordenar',
        'update' => 'Atualizar',
        'upload' => 'Enviar',
    ],

    'fields' => [
        'action' => 'Ação',
        'address' => 'Endereço',
        'author' => 'Autor',
        'category' => 'Categoria',
        'color' => 'Cor',
        'content' => 'Conteúdo',
        'date' => 'Data',
        'description' => 'Descrição',
        'enabled' => 'Ativado',
        'file' => 'Arquivo',
        'game' => 'Jogo',
        'icon' => 'Ícone',
        'image' => 'Imagem',
        'link' => 'Link',
        'money' => 'Dinheiro',
        'name' => 'Nome',
        'permissions' => 'Permissões',
        'port' => 'Porta',
        'price' => 'Preço',
        'published_at' => 'Publicado em',
        'quantity' => 'Quantidade',
        'role' => 'Função',
        'server' => 'Servidor',
        'short_description' => 'Descrição curta',
        'slug' => 'Slug',
        'status' => 'Status',
        'title' => 'Título',
        'type' => 'Tipo',
        'url' => 'URL',
        'user' => 'Usuário',
        'value' => 'Valor',
        'version' => 'Versão',
    ],

    'status' => [
        'success' => 'A ação foi concluída com sucesso!',
        'error' => 'Ocorreu um erro: :error',
    ],

    'range' => [
        'days' => 'Por dias',
        'months' => 'Por meses',
    ],

    'loading' => 'Carregando...',
    'select' => 'Selecionar...',

    'yes' => 'Sim',
    'no' => 'Não',
    'unknown' => 'Desconhecido',
    'other' => 'Outro',
    'none' => 'Nenhum',
    'copied' => 'Copiado',
    'icons' => 'Você pode encontrar a lista de ícones disponíveis em <a href="https://icons.getbootstrap.com/" target="_blank" rel="noopener noreferrer">Bootstrap Icons</a>.',

    'home' => 'Início',
    'servers' => 'Servidores',
    'news' => 'Notícias',
    'welcome' => 'Bem‑vindo ao :name',
    'copyright' => '',

    'maintenance' => [
        'title' => 'Manutenção',
        'message' => 'O site está atualmente em manutenção.',
    ],

    'theme' => [
        'light' => 'Tema claro',
        'dark' => 'Tema escuro',
    ],

    'captcha' => 'A verificação do captcha falhou, por favor tente novamente.',

    'notifications' => [
        'notifications' => 'Notificações',
        'read' => 'Marcar como lida',
        'empty' => 'Você não tem notificações não lidas.',
        'level' => 'Nível',
        'info' => 'Informação',
        'warning' => 'Aviso',
        'danger' => 'Perigo',
        'success' => 'Sucesso',
    ],

    'clipboard' => [
        'copied' => 'Copiado!',
        'error' => 'CTRL + C para copiar',
    ],

    'server' => [
        'join' => 'Entrar',
        'total' => ':count/:max jogador|:count/:max jogadores online',
        'online' => ':count jogador online|:count jogadores online',
        'offline' => 'O servidor está atualmente offline.',
    ],

    'profile' => [
        'title' => 'Meu perfil',
        'change_email' => 'Alterar endereço de e‑mail',
        'change_password' => 'Alterar senha',
        'change_name' => 'Alterar nome de usuário',
        'change_avatar' => 'Alterar avatar',
        'delete_avatar' => 'Excluir avatar',

        'email_limit' => 'Você não pode alterar seu endereço de e‑mail no momento, por favor tente novamente em alguns minutos.',

        'avatar' => 'O avatar deve ser quadrado e ter um tamanho mínimo de :size pixels.',

        'delete' => [
            'btn' => 'Excluir minha conta',
            'title' => 'Exclusão de conta',
            'info' => 'Isso excluirá permanentemente sua conta e os dados associados. Esta ação não pode ser desfeita.',
            'email' => 'Enviaremos um e‑mail de confirmação para confirmar esta operação.',
            'sent' => 'Um link de confirmação foi enviado para seu endereço de e‑mail.',
            'success' => 'Sua conta foi excluída com sucesso!',
        ],

        'email_verification' => 'Seu e‑mail não está verificado, por favor verifique seu e‑mail para ver o link de verificação.',
        'updated' => 'Seu perfil foi atualizado.',

        'info' => [
            'role' => 'Função: :role',
            'register' => 'Registrado: :date',
            'money' => 'Dinheiro: :money',
            '2fa' => 'Autenticação de Dois Fatores (2FA): :2fa',
            'discord' => 'Conta do Discord vinculada: :user',
        ],

        '2fa' => [
            'enable' => 'Ativar 2FA',
            'disable' => 'Desativar 2FA',
            'manage' => 'Gerenciar 2FA',
            'info' => 'Escaneie o código QR acima com um aplicativo de autenticação de dois fatores no seu telefone como <a href="https://authy.com/" target="_blank" rel="noopener norefferer">Authy</a>, <a href="https://secrets.app/" target="_blank" rel="noopener norefferer">Secrets</a> ou Google Authenticator.',
            'secret' => 'Chave secreta: :secret',
            'title' => 'Autenticação de Dois Fatores',
            'codes' => 'Mostrar códigos de recuperação',
            'code' => 'Código',
            'enabled' => 'A Autenticação de Dois Fatores está atualmente ativada. Não se esqueça de salvar seus códigos de recuperação!',
            'disabled' => 'Autenticação de Dois Fatores desativada.',
        ],

        'discord' => [
            'link' => 'Vincular ao Discord',
            'unlink' => 'Desvincular do Discord',
            'linked' => 'Sua conta do Discord foi vinculada com sucesso.',
        ],

        'money_transfer' => [
            'title' => 'Transferência de dinheiro',
            'user' => 'Este usuário não foi encontrado.',
            'balance' => 'Você não tem dinheiro suficiente para fazer esta transferência.',
            'success' => 'O dinheiro foi enviado com sucesso.',
            'notification' => ':user lhe enviou :money.',
        ],
    ],

    'posts' => [
        'posts' => 'Postagens',
        'posted' => 'Publicado em :date por :user',
        'unpublished' => 'Esta postagem não está publicada ainda.',
        'read' => 'Leia mais',
    ],

    'comments' => [
        'create' => 'Deixe um comentário',
        'guest' => 'Você deve estar logado para deixar um comentário.',
        'author' => '<strong>:user</strong> comentou em :date',
        'content' => 'Seu comentário',
        'delete' => 'Excluir?',
        'delete_confirm' => 'Tem certeza de que deseja excluir este comentário?',
    ],

    'auto' => 'Automático',

    'likes' => 'Curtidas: :count',

    'markdown' => [
        'init' => 'Anexe arquivos arrastando e soltando ou colando da área de transferência.',
        'drag' => 'Solte a imagem para enviá‑la.',
        'drop' => 'Enviando imagem #images_names#...',
        'progress' => 'Enviando #file_name#: #progress#%',
        'uploaded' => 'Enviado #image_name#',

        'size' => 'A imagem #image_name# é muito grande (#image_size#).\nO tamanho máximo do arquivo é #image_max_size#.',
        'error' => 'Algo deu errado ao enviar a imagem #image_name#.',
    ],

    'info' => 'Mais informações',

    'discord_roles' => [
        'id' => [
            'name' => 'ID da função',
            'description' => 'ID da função no site.',
        ],

        'power' => [
            'name' => 'Poder da função',
            'description' => 'Poder da função no site igual ou maior que',
        ],
    ],
];