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

## Zdjęcia zakupów

- Przy wydatku kliknij **📷** i dodaj zdjęcie paragonu albo produktów (do 10 zdjęć na wydatek).
- Zdjęcia są zmniejszane do ok. 1600 px i szyfrowane tym samym kluczem co dane. Na telefonie są w IndexedDB, nie w zwykłych danych.
- Synchronizacja: zdjęcie wysyła się do Supabase raz (osobna tabela `budget_photos`). Drugi telefon pobiera je, gdy zobaczy wydatek. Usunięcie zdjęcia lub wydatku usuwa je na obu telefonach.
- Kopia zapasowa (plik eksportu) **nie zawiera zdjęć**. Na nowym telefonie zdjęcia pojawią się po synchronizacji.
- **Jeśli Supabase skonfigurowaliście wcześniej,** uruchomcie ponownie cały `supabase/schema.sql` w SQL Editor. Nowe funkcje zdjęć nie zmieniają istniejących tabel.

## Produkty z paragonu (odczyt ze zdjęcia)

- W oknie zdjęć wydatku kliknij **🔍 Odczytaj produkty**. Aplikacja rozpoznaje tekst na zdjęciu i pokazuje listę: nazwa i cena.
- **Sprawdź i popraw** każdą pozycję. Dopiero kliknięcie **Zapisz produkty** dodaje je do wydatku. Ponowny odczyt tego samego zdjęcia zastępuje poprzednie produkty.
- Aplikacja porównuje sumę produktów z kwotą wydatku i pokazuje różnicę.
- Odczyt działa **w telefonie**: zdjęcie nigdzie nie jest wysyłane. Silnik OCR (Tesseract) i polski model języka są w katalogu `vendor/tesseract/`, więc działają też bez internetu.
- Pierwszy odczyt ładuje silnik (ok. 11 MB, zapamiętywane w pamięci podręcznej przeglądarki). Kolejne są szybsze.
- Dokładność zależy od zdjęcia: płaski paragon, dobre światło i ostre litery dają najlepsze wyniki. Zawsze sprawdzaj wynik.
- Produkty synchronizują się między telefonami jak reszta danych.

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

## Aplikacja na Androida (APK)

Gałąź `android-apk` buduje APK w GitHub Actions. Instalacja:

1. Wejdź na https://github.com/Adixonn02/Budzet_domowy/actions, otwórz najnowsze uruchomienie **Zbuduj APK** (zielony znacznik) i w sekcji **Artifacts** pobierz `nasz-budzet-apk`. Pobierze się archiwum ZIP.
2. Na telefonie rozpakuj ZIP (np. w aplikacji Pliki) i otwórz `app-debug.apk`.
3. Gdy system zapyta, zezwól na instalację z tego źródła (w Pliki albo przeglądarce).

**Podpis.** APK jest podpisany stałym kluczem z sekretów repozytorium GitHub. Kolejne wersje z tym samym kluczem instalują się nad poprzednimi i zachowują dane. Odcisk klucza widać w logu budowania (krok „Sprawdź podpis APK”).

**Przejście z wersji debug.** Wcześniejsza wersja była podpisana kluczem debug, więc przy pierwszej instalacji wersji ze stałym kluczem trzeba raz odinstalować starą aplikację:
1. Zrób kopię: Ustawienia → **Eksportuj do pliku**.
2. Odinstaluj starą aplikację (to kasuje jej dane).
3. Zainstaluj nowy APK, ustaw hasło i zaimportuj kopię.

Przy kolejnych aktualizacjach ten krok nie będzie potrzebny.

**Klucz podpisu (tylko właściciel).** Plik klucza i hasła trzymajcie w menedżerze haseł. Utrata klucza oznacza, że nie da się już wydać aktualizacji, którą system zainstaluje nad obecną wersją.

Artefakty GitHub wygasają po 30 dniach. Trwały link do APK wymaga wydania (Release), którego jeszcze nie ma.
