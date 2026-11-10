# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Um aplicativo macOS e uma extensão Safari para enviar downloads para o aplicativo **Downloads** de um UGREEN NAS em UGOS Pro, sem manter a página NAS aberta.

Fontes e versão DMG: **0.6.0**. Projeto comunitário independente, não afiliado à UGREEN ou Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

A interface do aplicativo e da extensão está disponível em 34 idiomas.

## Recursos

- Interceptação de links `.torrent` e `magnet:` em sites autorizados em Safari.
- Ação **Faça download para o NAS** clicando com o botão direito em um link, imagem, vídeo ou elemento de áudio diretamente acessível.
- Envio manual de um URL do menu de extensão.
- Conta e sessão no Keychain macOS; Suporte para autenticação de dois fatores e confiança no dispositivo.
- Pesquisa opcional de NAS pelo serviço online UGREEN ou endereço manual HTTPS.
- Lista de downloads, progresso e velocidade; conclusão opcional, desligamento e notificações de erro.
- Identificação de nomes e tipos de arquivos HTTP, com correção de nome após download quando o arquivo é identificado de forma inequívoca.
- Ícones claros e escuros nativos e logotipos Safari adaptados ao tema do sistema.

## Compatibilidade

O projeto está configurado para **macOS 27 ou posterior** e foi compilado com **Xcode 27.1**, para Apple Silicon. Os testes NAS foram realizados com **DXP2800**, **UGOS Pro 1.20.0.0142** e **Downloads 1.19.1.0004**. Outras versões não são garantidas: a integração é baseada em APIs observadas, sem contrato público UGREEN estável.

## Instalar do DMG

[Baixar UGREEN NAS Download 0.6.0 para Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Abra o DMG, arraste **UGREEN NAS Download** para **Aplicativos** e abra o aplicativo.
2. Em **Safari → Configurações → Avançado**, habilite recursos para desenvolvedores web. Em **Desenvolvedor**, ative **Permitir extensões não assinadas** e, em seguida, ative **UGREEN NAS Download** em **Extensões**.
3. Configure o NAS nas configurações de extensão.

Este pacote público é assinado localmente (ad hoc) e não é autenticado. macOS pode bloquear sua abertura inicial. Safari pode solicitar a reativação da permissão para extensões não assinadas após sair do navegador.

## Compilar da fonte

1. Clone este repositório e abra `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. Em **Assinatura e recursos**, escolha sua própria equipe Apple para os dois alvos: o aplicativo e sua extensão. Nenhuma equipe pessoal é inserida no repositório.
3. Escolha o esquema **UGREEN NAS Download**, destino **Meu Mac**, compile e inicie com Xcode.
4. Ative a extensão em **Safari → Configurações → Extensões** e autorize os sites desejados.
5. Abra as configurações de extensão e configure seu NAS conforme descrito abaixo.

Os IDs de pacote configurável de exemplo são `com.example.UGREENNASDownload` e `com.example.UGREENNASDownload.Extension`. Caso precise personalizá-los para sua assinatura, modifique os identificadores do projeto Xcode **e** as constantes correspondentes em `Extension/background.js` e `ViewController.swift`: os valores devem permanecer consistentes.

Esta edição pública utiliza identificadores e um espaço Keychain separado do aplicativo de desenvolvimento pessoal. Requer configuração própria do NAS. A assinatura de desenvolvimento não constitui uma distribuição autenticada e a ativação pode exigir as configurações de desenvolvimento Safari apropriadas para sua assinatura.

Para verificar uma compilação sem assinatura, na raiz do repositório:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Esta verificação produz um aplicativo não assinado; use sua equipe Apple para uma instalação de desenvolvimento utilizável em Safari. Mantenha a árvore do repositório: as referências Xcode a `Extension` e `Design` são relativas.

## Configurar o NAS

1. Insira o endereço HTTPS do NAS com sua porta, seu identificador e o caminho de destino absoluto no NAS. Os campos pessoais ficam vazios por padrão.
2. Clique em **Verificar certificado NAS**. Compare a impressão digital SHA-256 com uma fonte confiável antes de confirmar o certificado.
3. Digite a senha e, se necessário, um código de autenticação duplo. Confiar no dispositivo é opcional; sem ele, um novo código poderá ser necessário quando a sessão expirar.
4. Clique em **Salvar e testar conexão**. Permitir acesso à rede local quando solicitado por macOS.
5. Ative a interceptação automática de torrents e ímãs, se desejar. O clique com o botão direito e o envio manual permanecem independentes desta opção.

O endereço, conta e pasta ainda podem ser modificados nas configurações. **Esquecer esta conta** exclui a conta e sua sessão do Keychain para o perfil Safari atual.

## Segurança e Operação

As páginas da Web não podem configurar a conta ou confiar em um certificado. A extensão se comunica com seu módulo Swift por meio de mensagens nativas. As solicitações NAS passam por um mecanismo WebKit isolado com armazenamento efêmero e script de página desabilitados; o certificado deve corresponder à impressão digital aprovada. Os redirecionamentos NAS são recusados. A senha é criptografada com a chave RSA fornecida pelo NAS, para HTTPS.

A senha, o token e as informações de login são armazenados no Keychain, não no armazenamento da web ou neste repositório. O código temporário é apagado após o uso. Cookies e identificadores de sites Safari nunca são transmitidos para NAS. Para alguns torrents do mesmo site, o pequeno arquivo é recuperado na memória com a sessão Safari e depois transmitido para NAS sem salvamento local ou SMB; seu tamanho é limitado a 512 KiB.

A pesquisa automática consulta voluntariamente `api.ugnas.com`: este serviço vê o endereço IP público da conexão, mas não recebe senha ou token NAS. A entrada manual não depende deste serviço.

Nenhuma nova adição é tentada após uma resposta ambígua ou um prazo ter passado. Uma reconexão e uma nova tentativa só são permitidas após uma recusa explícita de autenticação. **Uma tarefa aceita pelo NAS não é prova de que o download foi concluído.**

## Limites

- Safari não substitui universalmente todos os seus downloads. A interceptação automática abrange links e mecanismos de torrent reconhecidos; clicar com o botão direito e inserir manualmente completa esta operação.
- Um link HTTP deve ser acessível diretamente pelo NAS. Conteúdos protegidos por sessão do site, URL expirados, vídeos protegidos e arquivos comuns gerados em `blob:` ou `data:` não são convertidos em links públicos.
- O rastreamento de menu aguarda aproximadamente 3,5 segundos após cada resposta; notificações e correções de nomes são verificadas aproximadamente a cada 30 segundos. Safari fechado, suspenso ou um Mac em suspensão pode atrasar essas operações.
- Formatos desconhecidos não recebem uma extensão inventada. A renomeação ocorre após a conclusão do download; o arquivo real é corrigido, enquanto o histórico de download pode manter seu nome original.
- As correções permanecem limitadas a novas tarefas HTTP identificadas de forma inequívoca, sem substituição forçada, com um máximo de 100 operações pendentes e uma retenção de sete dias. As listas são limitadas a 10.000 tarefas por categoria.
- A configuração global do ícone macOS permanece prioritária: **Escuro → Automático** permite que você siga o tema. O ícone estático na lista de extensões Safari permanece em sua versão transparente; os logotipos do menu e das opções seguem o tema.

## Desenvolvimento e teste

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

O teste de JavaScript requer Node.js; O teste nativo requer ferramentas macOS, Xcode, Python 3 e OpenSSL. Eles iniciam um servidor HTTPS local temporário na porta 18443 e não usam nenhuma conta NAS real. A auditoria 0.5.1 incluiu 45 testes de JavaScript e 121 controles nativos. Veja [o relatório](../AUDIT-0.5.1.md).

- `Extension/`: menu, configurações, scripts e ícones Safari.
- `Xcode/`: aplicação AppKit, módulo Swift, autenticação e transporte NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Ícone nativo com aparência clara e escura.
- `Design/generate-icons.swift`: geração de PNGs e logo adaptativo da janela.
- `Tests/`: testes de segurança, validação de dados e comportamento.

## Referências

- [ugnas-api](https://github.com/Fracizz/ugnas-api) cliente da comunidade: referência de protocolo, sem código de terceiros carregado de uma página NAS.
- [Integração comunitária UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referência para autenticação dupla.
- [Documentação da Apple Extensões da Web Safari](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Para relatar um problema, não anexe nenhuma senha, código temporário, token, URL assinado, torrent privado ou exportação de chaveiro. Use dados fictícios nos exemplos.
