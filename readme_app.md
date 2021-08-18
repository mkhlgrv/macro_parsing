# macroparsing
Парсинг открытых макроэкономических данных разной периодичности для России

 Источники:
 
 1. [Росстат](https://rosstat.gov.ru/): опросы, макроэкономческая статистика;
 
 2. [Московская биржа](https://moex.com/): биржевые индексы;
 
 3. [FRED](https://fred.stlouisfed.org/): индексы цен на товары, S&P 500, эффективный курс;
 
 4. [Federal Reserve Bank of Dallas](https://www.dallasfed.org/research/igrea): Index of Global Real Economic Activity;
 
 5. [Банк России](http://cbr.ru/): показатели денежного рынка, внешняя торговля в долларах, курсы валют;
 
 6. [OECD](https://data.oecd.org/): Composite leading indicator, Business confidence index, Consumer confidence index.

## Установка
### Установка из архива
Cкачайте архив и распакуйте его. 
Установите вспомогательный пакет devtools:
```r
install.packages("devtools")
```

Установите пакет macroparsing, в аргументе `path` указав путь к скачанному файлу *macroparsing_0.0.0.9000.tar.gz*:
```r
devtools::install_local(path = "C:/PATH/TO/REPO")
```
> **Для пользователей Windows:** В R при разделении имён директорий используется <kbd>/</kbd>

Подтвердите установку других пакетов, требуемых для работы.


### Рабочая директория и ключ API


Для скачивания данных c [FRED](https://fred.stlouisfed.org/) необходимо [получить](https://research.stlouisfed.org/docs/api/api_key.html) ключ API.
Более подробно об этом можно прочесть в [документации](https://cran.r-project.org/web/packages/fredr/vignettes/fredr.html#authentication) библиотеки `fredr`.

После установки пакета и получению ключа выполните команду, указав адрес рабочей директории `path` (в ней будут сохраняться все скачанные файлы) и ключ `fredr_api_key`:
```r
macroparsing::set.environment(path = "C:/PATH/TO/WORKING/DIR", fredr_api_key = "YourFredrAPIKey")
```
>  **Избегайте кириллических символов при выборе директории** 

Директория будет создана, если еще не существует. Внутри директории появится папка *data* для всех скачанных рядов.
 
После создания папки перезагрузите R.
 
Проверьте, что заданы необходимые глобальные переменные:

```r
Sys.getnev("directory")
Sys.getenv("fredr_api_key")
```
После выполнения этих команд вы должны получить указанный адрес рабочей директории и ключ FRED API.


## Пример использования пакета
Показать список доступных переменных:
```r
macroparsing::show.variables()
# удобное представление большой таблицы:
View(macroparsing::show.variables())
```

Показать список источников:
```r
macroparsing::sources
```
Скачать данные:
```r
macroparsing::download() # скачать все доступные временные ряды
macroparsing::download(ticker = c("RTSI", "SP500")) # скачать ряды по тикеру
macroparsing::download(source = "cbr")) # скачать все ряды по источнику
macroparsing::download(ticker = "cli_RUS",source = "dallasfed")) # объединение источника и тикера
```

Использовать параллелизацию процессов с пакетом `future`:
```r
macroparsing::download(use_future=TRUE) # все доступные временные ряды
```

## Приложение

Для запуска shiny-приложения скачайте пакеты shiny и ggplot2:
```r
install.packages("shiny", "ggplot2)
```

Запустите приложение, указав путь к распакованной папке с кодом приложения *app* из исходного архива (можно перенести папку *app* в уже созданную директорию `path`).
```r
shiny::runapp("app/macroparsing")
```

