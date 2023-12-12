#!/bin/bash

echo "Digite o nome: "
read -r nome

# Converter o nome para letras maiúsculas
nome=$(echo "$nome" | tr 'a-z' 'A-Z')

echo "Digite a data de nascimento (no formato DD/MM/AAAA): "
read -r data_nascimento

# Verificar se a data de nascimento é válida
if [[ ! $data_nascimento =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
    echo "Data de nascimento inválida. Certifique-se de que está no formato DD/MM/AAAA."
    exit 1
fi

# Extrair dia, mês e ano da data de nascimento
IFS="/" read -r dia mes ano <<< "$data_nascimento"

# Função para calcular a soma dos dígitos de um número
soma_digitos() {
    local num="$1"
    local soma=0
    for ((i = 0; i < ${#num}; i++)); do
        soma=$((soma + ${num:i:1}))
    done
    echo "$soma"
}

# Calcular a soma dos dígitos do dia, mês e ano de nascimento
soma_dia=$(soma_digitos "$dia")
soma_mes=$(soma_digitos "$mes")
soma_ano=$(soma_digitos "$ano")

# Calcular a soma da data de nascimento e reduzir para um único dígito
soma_data=$((soma_dia + soma_mes + soma_ano))
soma_data=$(soma_digitos "$soma_data")

# Função para reduzir um valor numerológico para um único dígito
reduzir_para_digito() {
    local valor=$1
    while [ $valor -gt 9 ]; do
        local novo_valor=0
        while [ $valor -gt 0 ]; do
            novo_valor=$((novo_valor + valor % 10))
            valor=$((valor / 10))
        done
        valor=$novo_valor
    done
    echo $valor
}

# Reduzir a soma da data de nascimento para um único dígito
soma_data=$(reduzir_para_digito $soma_data)

# Inicializar as variáveis que armazenarão os valores numerológicos
valor_numerologico_total=0
valor_numerologico_consoantes=0
valor_numerologico_vogais=0

# Inicializar o alfabeto
alfabeto="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Inicializar variáveis para armazenar letras faltando e letras repetidas
letras_faltando=""
letras_repetidas=""

# Loop através de cada caractere no nome
for ((i = 0; i < ${#nome}; i++)); do
    letra=${nome:i:1}
    valor_letra=$((($(printf "%d" "'$letra") - 64) % 32)) # Converte a letra para um valor de 1 a 26
    valor_numerologico_total=$((valor_numerologico_total + valor_letra))

    # Verificar se a letra é uma vogal ou consoante
    case $letra in
    [AEIOU]) valor_numerologico_vogais=$((valor_numerologico_vogais + valor_letra)) ;;
    [BCDFGHJKLMNPQRSTVWXYZ]) valor_numerologico_consoantes=$((valor_numerologico_consoantes + valor_letra)) ;;
    esac

    # Remover a letra do alfabeto
    alfabeto=${alfabeto//$letra/}

    # Verificar letras repetidas
    count=$(grep -o -i "$letra" <<<"$nome" | wc -l)
    if [ $count -gt 1 ]; then
        if [[ "$letras_repetidas" != *"$letra"* ]]; then
            letras_repetidas+="$letra "
        fi
    fi
done

# Verificar as letras faltando
letras_faltando="$alfabeto"

# Reduzir os valores numerológicos para um único dígito
valor_numerologico_total=$(reduzir_para_digito $valor_numerologico_total)
valor_numerologico_consoantes=$(reduzir_para_digito $valor_numerologico_consoantes)
valor_numerologico_vogais=$(reduzir_para_digito $valor_numerologico_vogais)

calcular_valor_nao_reduzido_nome() {
    local nome="$1"
    local valor=0
    for ((i = 0; i < ${#nome}; i++)); do
        letra=${nome:i:1}
        valor_letra=$((($(printf "%d" "'$letra") - 64) % 32)) # Converte a letra para um valor de 1 a 26
        valor=$((valor + valor_letra))
    done
    echo "$valor"
}

calcular_valor_nao_reduzido_data_nascimento() {
    local data="$1"
    IFS="/" read -r dia mes ano <<< "$data"
    local soma_dia=$(soma_digitos "$dia")
    local soma_mes=$(soma_digitos "$mes")
    local soma_ano=$(soma_digitos "$ano")
    local soma_data=$((soma_dia + soma_mes + soma_ano))
    echo "$soma_data"
}

calcular_valor_nao_reduzido_vogais() {
    local nome="$1"
    local valor=0
    for ((i = 0; i < ${#nome}; i++)); do
        letra=${nome:i:1}
        case $letra in
        [AEIOU]) valor_letra=$((($(printf "%d" "'$letra") - 64) % 32)) # Converte a letra para um valor de 1 a 26
                 valor=$((valor + valor_letra))
                 ;;
        esac
    done
    echo "$valor"
}

calcular_valor_nao_reduzido_consoantes() {
    local nome="$1"
    local valor=0
    for ((i = 0; i < ${#nome}; i++)); do
        letra=${nome:i:1}
        case $letra in
        [BCDFGHJKLMNPQRSTVWXYZ]) valor_letra=$((($(printf "%d" "'$letra") - 64) % 32)) # Converte a letra para um valor de 1 a 26
                                 valor=$((valor + valor_letra))
                                 ;;
        esac
    done
    echo "$valor"
}


# Chamar a função para calcular o valor não reduzido do nome
valor_nao_reduzido_nome=$(calcular_valor_nao_reduzido_nome "$nome")

# Chamar a função para calcular o valor não reduzido da data de nascimento
valor_nao_reduzido_data=$(calcular_valor_nao_reduzido_data_nascimento "$data_nascimento")

# Chamar a função para calcular o valor não reduzido das vogais
valor_nao_reduzido_vogais=$(calcular_valor_nao_reduzido_vogais "$nome")

# Chamar a função para calcular o valor não reduzido das consoantes
valor_nao_reduzido_consoantes=$(calcular_valor_nao_reduzido_consoantes "$nome")



# Exibir os valores numerológicos, letras repetidas e letras faltando
echo "Valor numerológico total para $nome (reduzida para um dígito): $valor_numerologico_total | valor não reduzido:  $valor_nao_reduzido_nome"
echo "Valor numerológico das consoantes (reduzida para um dígito): $valor_numerologico_consoantes | valor não reduzido: $valor_nao_reduzido_consoantes"
echo "Valor numerológico das vogais (reduzida para um dígito): $valor_numerologico_vogais | valor não reduzido: $valor_nao_reduzido_vogais"
echo "Soma da data de nascimento (reduzida para um dígito): $soma_data | valor não reduzido: $valor_nao_reduzido_data"
echo "Letras faltando no nome: $letras_faltando"
echo "Letras repetidas no nome: $letras_repetidas" 
