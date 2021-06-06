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
Cкачайте репозиторий и установите его. В аргументе `path` укажите путь к скачанному файлу:
```r
devtools::install_local(path = "C:/PATH/TO/REPO")
```
> :warning: **Для пользователей Windows:** В R при разделении имён директорий используется <kbd>/</kbd>

Для скачивания данных c [FRED](https://fred.stlouisfed.org/) необходимо [получить](https://research.stlouisfed.org/docs/api/api_key.html) ключ API.
Более подробно об этом можно прочесть в [документации](https://cran.r-project.org/web/packages/fredr/vignettes/fredr.html#authentication) библиотеки `fredr`.

## Использование
Показать список доступных переменных:
```r
macroparsing::variables
```
Скачать данные:
```r
macroparsing::download() # все доступные временные ряды
macroparsing::download(ticker = c("RTSI", "SP500")) # по тикеру
macroparsing::download(source = "cbr")) # по источнику
macroparsing::download(ticker = "cli_RUS",source = "dallasfed")) # объединение источника и тикера
```

Использовать параллелизацию процессов с пакетом `future`:
```r
macroparsing::download(use_future=TRUE) # все доступные временные ряды
```

## Рабочая директория и ключ API
После установки пакета и получению ключа выполните команду, указав адрес рабочей директории `path` (в ней будут сохраняться все скачанные файлы) и ключ `fredr_api_key`:
```r
macroparsing::set.enviroment(path = "C:/PATH/TO/WORKING/DIR", fredr_api_key = "YourFredrAPIKey")
```
> :warning: **Избегайте кириллических символов при выборе директории** 

Директория будет создана, если еще не существует. Внутри директории появятся:
 - *.Renviron*: файл с внутренними переменными, нужен для стабильной работы пакета;
 - *data/raw_excel/:* хранилище всех скачанных excel-файлов;
 - *data/raw*: хранилище скачанных временных рядов в исходном виде в формате *.csv*. При создании директории файлы будут пустыми;
 - *data/out* первично обработанные временные ряды в формате *.csv*.
