<?php

return [
    'error' => 'Erro',
    'code' => 'Erro :code',
    'home' => 'Voltar para a página inicial',
    'whoops' => 'Ops!',

    '401' => [
        'title' => 'Não autorizado',
        'message' => 'Você não está autorizado a acessar esta página.',
    ],
    '403' => [
        'title' => 'Proibido',
        'message' => 'Você está proibido de acessar esta página.',
    ],
    '404' => [
        'title' => 'Não encontrado',
        'message' => 'A página que você está procurando não pôde ser encontrada.',
    ],
    '419' => [
        'title' => 'Página expirada',
        'message' => 'Sua sessão expirou. Por favor, atualize e tente novamente.',
    ],
    '429' => [
        'title' => 'Muitas solicitações',
        'message' => 'Você está fazendo muitas solicitações aos nossos servidores. Por favor, tente novamente mais tarde.',
    ],
    '500' => [
        'title' => 'Erro do servidor',
        'message' => 'Ops, algo deu errado em nossos servidores. Por favor, tente novamente mais tarde.',
    ],
    '503' => [
        'title' => 'Serviço indisponível',
        'message' => 'Estamos fazendo alguma manutenção. Por favor, volte em breve.',
    ],

    'fallback' => [
        'message' => 'Ocorreu um erro. Por favor, tente novamente.',
    ],
];