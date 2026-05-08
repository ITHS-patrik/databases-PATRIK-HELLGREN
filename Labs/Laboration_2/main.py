# SOURCES:
    # create_engine:    https://docs.sqlalchemy.org/en/20/core/engines_connections.html
    # text:             https://docs.sqlalchemy.org/en/14/core/sqlelement.html
    # sessionmaker:     https://docs.sqlalchemy.org/en/20/orm/session_api.html
    # rich:             https://rich.readthedocs.io/en/latest/introduction.html

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

import os, subprocess

from rich import print
from rich.panel import Panel
from rich.prompt import Prompt
from rich.table import Table
from rich.align import Align
from rich.console import Console, Group

console = Console()
print = console.print

# NOTE: In a real project, I would've stored the password in an environment variable or .env file.
CONNECTION_STRING = ("mssql+pyodbc://PythonLogin:MyUltraStrongPassword123!"
                     "@localhost/PatrikHellgren?driver=ODBC+Driver+17+for+SQL+Server")


def clear_terminal():
    try:
        command = "cls" if os.name == "nt" else "clear"
        subprocess.run(command, shell=True, check=True)
    except Exception:
        print("\n" * 3)


try:
    clear_terminal()

    engine = create_engine(url=CONNECTION_STRING)
    engine.connect()

    SessionLocal = sessionmaker(bind=engine, autoflush=False)
except:
    error = Group(
        Align.center("\n[red]Kunde inte ansluta till databasen.[/red]"),
        "\n"
        "Möjliga orsaker:\n"
        "• Fel användarnamn eller lösenord i connection string\n"
        "• Fel servernamn eller databasnamn i connection string\n"
        "• ODBC-drivern saknas eller har fel version\n"
        "• SQL Server är inte igång\n"
        "• SQL Server Authentication är avstängt (SSMS)\n"
        "• TCP/IP är avstängt i SQL Server Configuration Manager\n"
        "• Brandväggen blockerar port 1433\n")
    print(Panel(error, title="❌ Anslutningsfel", border_style="red", expand=False))
    raise SystemExit(1)


def search_books(search_term: str):
    query = text("""
        SELECT 
            ISBN13 AS ISBN, 
            Title AS Boktitel
        FROM Books
        WHERE Title LIKE :term
    """)
    params = {"term": f"%{search_term}%"}

    with SessionLocal() as session:
        return session.execute(query, params).fetchall()


def display_books(books: list):
    console.line()
    results = Table()

    results.add_column("ID", justify="right", style="cyan", no_wrap=True)
    results.add_column("ISBN13", justify="center", style="magenta")
    results.add_column("Titel", style="green")

    for idx, (isbn, title) in enumerate(books, start=1):
        results.add_row(str(idx), isbn, title)

    print(results)


def get_stock_levels(isbn: str):
    query = text("""
        SELECT 
            s.Name AS Butiksnamn, 
            sq.StockQuantity AS Lagersaldo
        FROM StockQuantities sq
        JOIN Stores s 
            ON s.ID = sq.StoreId
        WHERE sq.ISBN13 = :isbn
    """)
    params = {"isbn": f"{isbn}"}

    with SessionLocal() as session:
        return session.execute(query, params).fetchall()


def display_stock_levels(stock: list, book_title: str):
    console.line()
    stock_levels = Table(title=f"{book_title}", title_justify="left", title_style="green italic")

    stock_levels.add_column("Butiksnamn", style="magenta", no_wrap=True)
    stock_levels.add_column("Lagersaldo", style="green", justify="right")

    for store_name, stock_level in stock:
        stock_levels.add_row(store_name, f"{stock_level} st")

    print(stock_levels)


def main():
    clear_terminal()

    print(Panel("[bold dark_orange3]Välkommen till Akademibokhandeln![/bold dark_orange3]", expand=False))

    mode = "search"

    while True:
        if mode == "search":
            keyword = Prompt.ask("\n[blue]Sök boktitel eller skriv 'stopp' för att avbryta[/blue]").strip()
            if keyword.lower() == "stopp":
                print()
                print(Panel("Tack och välkommen åter!", style="bold dark_orange3", border_style="white", expand=False, title="🤓"))
                print()
                break

            books = search_books(keyword)
            if not books:
                print("  ⚠️   Inga sökträffar, försök igen.")
                continue
            display_books(books)

            mode = "stock"

        if mode == "stock":
            choice = Prompt.ask("\n[blue]Ange rad-ID för att visa lagersaldo i alla butiker eller skriv 'sök' för att söka om[/blue]").strip()
            if choice.lower() == "sök":
                mode = "search"
                continue
            if choice.lower() == "stopp":
                print()
                print(Panel("Tack och välkommen åter!", style="bold dark_orange3", border_style="white", expand=False, title="🤓"))
                print()
                break

            try:
                chosen_id = int(choice)
                isbn = books[chosen_id - 1][0]
            except:
                print(f"  ⚠️   Ogiltigt rad-ID ('{choice}'), försök igen.")
                continue

            stock = get_stock_levels(isbn)
            if not stock:
                print('  ⚠️   Denna bok finns inte i saldo i någon av våra butiker eller så är inmatningen ogiltig. Försök igen.')
                continue
            display_stock_levels(stock, books[chosen_id - 1][1])


if __name__ == "__main__":
    main()
