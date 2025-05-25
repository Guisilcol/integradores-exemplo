# Gerenciador de Regras do AWS EventBridge com Terraform

Este projeto utiliza Terraform para gerenciar regras do AWS EventBridge. Ele lê configurações de regras de arquivos JSON localizados em um diretório especificado e cria/atualiza essas regras no EventBridge.

## Visão Geral

O projeto é estruturado para simplificar a criação e o gerenciamento de múltiplas regras do EventBridge. Ele utiliza um módulo Terraform (`eventbridge_rules`) que itera sobre arquivos JSON em um diretório (por padrão, `eventbridge-integrator/rules/`) e cria os recursos correspondentes no AWS EventBridge.

## Arquivos Principais

-   [`eventbridge-integrator/main.tf`](eventbridge-integrator/main.tf): Arquivo principal do Terraform que define o provedor AWS e invoca o módulo `eventbridge_rules`.
-   [`eventbridge-integrator/variables.tf`](eventbridge-integrator/variables.tf): Define as variáveis de entrada para a configuração do Terraform.
-   [`eventbridge-integrator/terraform.tfvars`](eventbridge-integrator/terraform.tfvars): Fornece valores para as variáveis definidas em `variables.tf`.
-   [`eventbridge-integrator/modules/eventbridge_rules/main.tf`](eventbridge-integrator/modules/eventbridge_rules/main.tf): Módulo Terraform responsável por ler os arquivos JSON de regras e criar os recursos `aws_cloudwatch_event_rule`, `aws_cloudwatch_event_target`, e `aws_lambda_permission`.
-   [`eventbridge-integrator/rules/`](eventbridge-integrator/rules/): Diretório contendo as definições das regras do EventBridge em formato JSON. Exemplos incluem [`example-event.json`](eventbridge-integrator/rules/example-event.json) e [`example-scheduled.json`](eventbridge-integrator/rules/example-scheduled.json).

## Pré-requisitos

-   Terraform instalado
-   Credenciais AWS configuradas com as permissões necessárias.
-   Uma IAM Role existente para o EventBridge.

## Requisitos da IAM Role

A IAM Role especificada na variável `eventbridge_role_arn` (definida em [`eventbridge-integrator/terraform.tfvars`](eventbridge-integrator/terraform.tfvars)) deve ter as seguintes permissões:

1.  **Política de Confiança (Trust Policy):**
    A role deve permitir que o serviço `events.amazonaws.com` a assuma. Exemplo de política de confiança:

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "events.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
    ```

2.  **Permissões para Executar Targets:**
    A role deve ter permissões para executar as ações definidas nos targets das regras do EventBridge. Por exemplo, se um target invoca uma função Lambda, a role precisará da permissão `lambda:InvokeFunction` para a função Lambda específica. Se um target envia uma mensagem para uma fila SQS, precisará da permissão `sqs:SendMessage` para a fila específica.

    Exemplo de política de permissões para invocar qualquer função Lambda (restrinja conforme necessário):
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "lambda:InvokeFunction",
                "Resource": "arn:aws:lambda:*:*:function:*"
            }
        ]
    }
    ```

## Configuração

1.  Clone o repositório.
2.  Navegue até o diretório `eventbridge-integrator`.
3.  Modifique o arquivo [`eventbridge-integrator/terraform.tfvars`](eventbridge-integrator/terraform.tfvars) com os valores desejados para as variáveis, como `aws_region`, `account_id`, `eventbridge_role_arn`, `rules_directory`, e `event_bus_name`.
4.  Adicione ou modifique os arquivos JSON de definição de regras no diretório especificado por `rules_directory` (por padrão, [`eventbridge-integrator/rules/`](eventbridge-integrator/rules/)).

## Uso

No diretório `eventbridge-integrator`:

1.  Inicialize o Terraform:
    ```sh
    terraform init
    ```
2.  Planeje as alterações:
    ```sh
    terraform plan
    ```
3.  Aplique as alterações:
    ```sh
    terraform apply
    ```

Para remover os recursos criados:
```sh
terraform destroy
```

## Estrutura dos Arquivos JSON de Regras

Cada arquivo `.json` no diretório `rules_directory` deve definir uma regra do EventBridge. O módulo espera uma estrutura específica nesses arquivos. Consulte o arquivo [`eventbridge-integrator/modules/eventbridge_rules/main.tf`](eventbridge-integrator/modules/eventbridge_rules/main.tf) e os exemplos em [`eventbridge-integrator/rules/`](eventbridge-integrator/rules/) para entender a estrutura esperada.
Tipicamente, um arquivo de regra pode conter:
- `name`: Nome da regra.
- `description`: Descrição da regra.
- `event_pattern`: Padrão de evento (para regras acionadas por eventos).
- `schedule_expression`: Expressão de agendamento (para regras agendadas).
- `targets`: Uma lista de alvos para a regra, cada um especificando o ARN do recurso alvo e, opcionalmente, uma entrada (input).
- `enabled`: (Opcional) Booleano para habilitar ou desabilitar a regra, sobrescrevendo o padrão `rules_enabled_by_default`.
