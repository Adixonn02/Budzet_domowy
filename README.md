# Nasz budżet 🏠

Aplikacja do wspólnego budżetu dla pary. To aplikacja PWA: instaluje się na telefonie jak zwykła aplikacja, działa offline i szyfruje dane hasłem.

## Pliki

- `index.html`: cała aplikacja.
- `manifest.json`, `sw.js`, `icons/`: instalacja na telefonie i tryb offline.
- `supabase/schema.sql`: schemat bazy do synchronizacji (ten sam kod jest w Ustawieniach, z przyciskiem „Kopiuj SQL”).

## Jak zainstalować na telefonie

Aplikacja musi działać pod adresem **https** (np. GitHub Pages albo Netlify). Otwieranie samego pliku z telefonu nie wystarczy, bo szyfrowanie i instalacja wymagają bezpiecznego adresu.

- **Android (Chrome):** wejdź na adres aplikacji → menu (⋮) → **Zainstaluj aplikację**.
- **iPhone (Safari):** wejdź na adres aplikacji → Udostępnij → **Do ekranu początkowego**.

Po instalacji ikona „Budżet” pojawia się na ekranie głównym, a aplikacja działa także bez internetu.

## Hasło do danych

- Przy pierwszym uruchomieniu ustawiacie hasło (min. 8 znaków). Dane na telefonie i w synchronizacji są szyfrowane tym hasłem.
- Hasło pytamy **raz na telefon**. Potem telefon je pamięta i aplikacja otwiera się od razu.
- **Hasła nie da się odzyskać.** Bez niego dane są nie do odczytania. Zapisz je w menedżerze haseł.
- Ustawienia → **Zablokuj aplikację na tym telefonie** wymaga hasła przy następnym otwarciu. Warto użyć tego, gdy oddajesz telefon komuś innemu.
- Gdy wyczyścisz dane przeglądarki, aplikacja poprosi o hasło ponownie.

## Synchronizacja między telefonami (Supabase)

Jednorazowa konfiguracja, ok. 5 minut:

1. Załóż konto na supabase.com i utwórz nowy projekt (darmowy plan wystarczy).
2. W projekcie otwórz **SQL Editor → New query**, wklej zawartość `supabase/schema.sql` i kliknij **Run**.
3. Przejdź do **Project Settings → API** i skopiuj **Project URL** oraz klucz **anon public**. Nigdy nie używaj klucza `service_role`.
4. **Pierwszy telefon:** Ustawienia → Synchronizacja → **Utwórz wspólny budżet**, wpisz adres i klucz. Skopiuj kod połączenia przyciskiem „Kopiuj kod”.
5. **Drugi telefon:** otwórz aplikację, wybierz **Dołączam do budżetu partnera**, wklej kod i wpisz **to samo hasło**. Jeśli hasło się nie zgadza, aplikacja tego nie zapisze.

Jak to działa:

- Zmiany wysyłają się automatycznie po kilku sekundach. Aplikacja odświeża się też co 30 sekund, gdy jest otwarta.
- Gdy oboje edytujecie ten sam rekord naraz, wygrywa późniejsza zmiana. Rekordy edytowane osobno łączą się bez utraty danych.
- Usunięcia też się synchronizują.
- Bez internetu aplikacja działa normalnie. Zmiany wysyłają się po powrocie połączenia.

Ważne:

- **Kod połączenia to nie wszystko.** Sam kod nie pozwala odczytać danych, bo potrzebne jest jeszcze hasło. Mimo to nie wysyłaj kodu w publicznym miejscu.
- W Supabase widać tylko zaszyfrowany zapis (`enc`), nie kwoty ani opisy.

## Kopia zapasowa

Ustawienia → **Eksportuj do pliku** tworzy kopię zaszyfrowaną osobnym hasłem, które podajesz przy eksporcie (może być inne niż hasło do danych). Import łączy dane z pliku z obecnymi i nic nie kasuje. Na drugim telefonie importujesz plik i podajesz hasło do kopii.

Przechowuj kopie w bezpiecznym miejscu. Nawet zaszyfrowana kopia jest bezwartościowa bez hasła, więc zapisz i je.

## Zakładki

- **Przegląd** (ekran startowy): karta „Najbliższe 14 dni” z wydarzeniami i ratami z sumą, kwota „Do dyspozycji”, dochody, raty, limity, rezerwa na wydarzenia, budżet w miesiącu i rozliczenie wspólnych wydatków.
- **Budżet**: dochody obojga, kategorie z ikonami, kolorami i limitami oraz lista wydatków. Przy każdym wydatku możesz od razu zmienić kategorię. Filtr pokazuje np. tylko „Bez kategorii”.
- **Wykresy**: wykres kołowy (na co poszły pieniądze), wydane kwoty w porównaniu z limitami i trend z ostatnich 6 miesięcy.
- **Kalendarz**: wydarzenia (urodziny, prezenty, wyjazdy). Przycisk **Opłać** dodaje wydatek do budżetu. Wydarzenia cykliczne przesuwają się same na kolejny rok.
- **Zobowiązania**: raty, pożyczki i kredyty z postępem spłaty.
- **Ustawienia**: imiona, synchronizacja, kopia zapasowa, blokada i dane przykładowe.

## Kategorie

- Podpowiedź kategorii: wpisując opis wydatku (np. „Lidl”), aplikacja sama wybiera kategorię na podstawie historii i słów kluczowych. Ręczny wybór nie jest nadpisywany.
- Usunięcie kategorii nie kasuje wydatków. Trafiają do „Bez kategorii”, a w Budżecie pojawia się licznik „Do skategoryzowania”.

## Jak liczone są wartości

- **Do dyspozycji** = dochody − raty − limity kategorii − rezerwa na wydarzenia.
- **Rezerwa na wydarzenie** = kwota ÷ liczba miesięcy do terminu (minimum 1).
- **Rozliczenie**: wydatki „Wspólny 50/50” dzielicie po połowie. Saldo pokazuje, kto komu oddaje różnicę. Wydatki „Osobiste” się nie rozliczają.
- **Raty**: następna płatność to najbliższy wybrany dzień miesiąca. Opłacenie raty przed terminem przesuwa termin na kolejny miesiąc.
- **Limit 0** oznacza brak limitu.
