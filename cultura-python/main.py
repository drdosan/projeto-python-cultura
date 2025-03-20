import sys
import json

# Lista fixa de insumos disponíveis para cada cultura
INSUMOS_CAFE = ["Fosfato Monoamônico (MAP)", "Sulfato de Amônio", "Calcário Dolomítico"]
INSUMOS_CANA = ["Ureia", "Cloreto de Potássio", "Superfosfato Simples"]

# Lista para armazenar os dados das plantações
plantacoes = []


def calcular_area(diagonal_maior, diagonal_menor):
    """Calcula a área do losango"""
    return (diagonal_maior * diagonal_menor) / 2


def calcular_quantidade_ruas(diagonal_maior, espacamento):
    """Calcula a quantidade de ruas na lavoura e arredonda para o inteiro mais próximo"""
    return round(diagonal_maior / espacamento)


def calcular_insumos(area, dosagem, ruas, espacamento):
    """Calcula a quantidade total de insumos necessários, descontando a área ocupada pelas ruas"""
    area_util = area - (ruas * espacamento)
    if area_util < 0:
        area_util = 0  # Para evitar valores negativos caso o espaçamento seja maior que a área
    return round(area_util * dosagem)  # Arredonda o total de insumos em litros


def escolher_insumo(cultura):
    """Permite escolher um dos insumos disponíveis para a cultura selecionada"""
    insumos_disponiveis = INSUMOS_CAFE if cultura == "café" else INSUMOS_CANA
    print("\n📌 Escolha um dos insumos disponíveis para esta cultura:")
    for i, insumo in enumerate(insumos_disponiveis, start=1):
        print(f"{i}. {insumo}")

    while True:
        try:
            escolha = int(input("\nDigite o número correspondente ao insumo desejado: "))
            if 1 <= escolha <= len(insumos_disponiveis):
                return insumos_disponiveis[escolha - 1]
            else:
                print("❌ Escolha inválida! Digite um número entre 1 e", len(insumos_disponiveis))
        except ValueError:
            print("❌ Entrada inválida! Digite um número válido.")


def adicionar_plantacao():
    """Entrada de dados para uma nova plantação"""
    nome = input("Informe o nome da plantação: ").strip()

    cultura = input("Informe a cultura (Café ou Cana-de-açúcar): ").strip().lower()
    if cultura not in ["café", "cana-de-açúcar"]:
        print("Cultura inválida! Escolha entre Café ou Cana-de-açúcar.")
        return

    insumo_escolhido = escolher_insumo(cultura)

    d_maior = float(input("Informe a diagonal maior (em metros): "))
    d_menor = float(input("Informe a diagonal menor (em metros): "))
    area = calcular_area(d_maior, d_menor)

    dosagem = float(input("Informe a dosagem de insumos (L/m²): "))

    espacamento = 3.6 if cultura == "café" else 1.5

    ruas = calcular_quantidade_ruas(d_maior, espacamento)
    insumo_total = calcular_insumos(area, dosagem, ruas, espacamento)

    plantacoes.append({
        "Nome": nome,
        "Cultura": cultura,
        "Insumo": insumo_escolhido,
        "Diagonal Maior": d_maior,
        "Diagonal Menor": d_menor,
        "Área (m²)": area,
        "Dosagem (L/m²)": dosagem,
        "Espaçamento entre Linhas (m)": espacamento,
        "Quantidade de Ruas": ruas,
        "Insumo Total (L)": insumo_total
    })

    print("\n✅ Dados cadastrados com sucesso!\n")


def listar_plantacoes():
    """Exibe os dados cadastrados"""
    if not plantacoes:
        print("\n🚫 Nenhuma plantação cadastrada.\n")
        return

    print("\n📋 Lista de Plantações:")
    for i, p in enumerate(plantacoes):
        print(f"{i + 1}. Nome: {p['Nome']}, Cultura: {p['Cultura']}, Insumo: {p['Insumo']}, "
              f"Área: {p['Área (m²)']} m², Ruas: {p['Quantidade de Ruas']}, Insumo Total: {p['Insumo Total (L)']} L")
    print()


def exportar_json():
    """Imprime os dados das plantações no formato JSON no terminal"""
    if not plantacoes:
        print("\n🚫 Nenhuma plantação cadastrada para exportar.\n")
        return

    print("\n📤 JSON das Plantações (Copie e cole no R):\n")
    print(json.dumps(plantacoes, ensure_ascii=False, indent=4))


def atualizar_plantacao():
    """Atualiza um registro de plantação"""
    listar_plantacoes()

    if not plantacoes:
        return

    indice = int(input("Informe o número da plantação para atualizar: ")) - 1
    if 0 <= indice < len(plantacoes):
        print("\n🔄 Atualizando dados da plantação...\n")

        novo_nome = input(f"Novo nome (Atual: {plantacoes[indice]['Nome']}): ").strip()
        if novo_nome:
            plantacoes[indice]["Nome"] = novo_nome

        nova_cultura = input(
            f"Nova cultura (Atual: {plantacoes[indice]['Cultura']}, opções: Café ou Cana-de-açúcar): ").strip().lower()
        if nova_cultura in ["café", "cana-de-açúcar"]:
            plantacoes[indice]["Cultura"] = nova_cultura
            plantacoes[indice]["Espaçamento entre Linhas (m)"] = 3.6 if nova_cultura == "café" else 1.5
            plantacoes[indice]["Insumo"] = escolher_insumo(nova_cultura)

        d_maior = float(input(f"Nova diagonal maior (Atual: {plantacoes[indice]['Diagonal Maior']} metros): "))
        d_menor = float(input(f"Nova diagonal menor (Atual: {plantacoes[indice]['Diagonal Menor']} metros): "))
        nova_area = calcular_area(d_maior, d_menor)
        plantacoes[indice]["Diagonal Maior"] = d_maior
        plantacoes[indice]["Diagonal Menor"] = d_menor
        plantacoes[indice]["Área (m²)"] = nova_area

        nova_dosagem = float(input(f"Nova dosagem de insumos (Atual: {plantacoes[indice]['Dosagem (L/m²)']}): "))
        plantacoes[indice]["Dosagem (L/m²)"] = nova_dosagem

        novas_ruas = calcular_quantidade_ruas(d_maior, plantacoes[indice]["Espaçamento entre Linhas (m)"])
        plantacoes[indice]["Quantidade de Ruas"] = novas_ruas
        plantacoes[indice]["Insumo Total (L)"] = calcular_insumos(nova_area, nova_dosagem, novas_ruas,
                                                                  plantacoes[indice]["Espaçamento entre Linhas (m)"])

        print("\n✅ Dados atualizados com sucesso!\n")
    else:
        print("\n🚫 Índice inválido.\n")


def remover_plantacao():
    """Remove um registro de plantação"""
    listar_plantacoes()

    if not plantacoes:
        return

    indice = int(input("Informe o número da plantação para remover: ")) - 1
    if 0 <= indice < len(plantacoes):
        del plantacoes[indice]
        print("\n✅ Plantação removida com sucesso!\n")
    else:
        print("\n🚫 Índice inválido.\n")


def menu():
    """Exibe o menu principal"""
    while True:
        print("=== 🌱 MENU PRINCIPAL 🌱 ===")
        print("1️⃣  Adicionar Plantação")
        print("2️⃣  Listar Plantações")
        print("3️⃣  Atualizar Plantação")
        print("4️⃣  Remover Plantação")
        print("5️⃣  Exportar para R")
        print("6️⃣  Sair")

        opcao = input("Escolha uma opção: ")

        if opcao == "1":
            adicionar_plantacao()
        elif opcao == "2":
            listar_plantacoes()
        elif opcao == "3":
            atualizar_plantacao()
        elif opcao == "4":
            remover_plantacao()
        elif opcao == "5":
            exportar_json()
        elif opcao == "6":
            print("🚪 Encerrando o programa...")
            sys.exit()
        else:
            print("🚫 Opção inválida! Tente novamente.")


# Executa o menu
menu()
