Перем юТест;

Функция ПолучитьСписокТестов(ЮнитТестирование) Экспорт
	
	юТест = ЮнитТестирование;
	
	ВсеТесты = Новый Массив;
	
	ВсеТесты.Добавить("ТестДолжен_ПолучитьПутьКOscript");
	ВсеТесты.Добавить("ТестДолжен_ПроверитьРаботуЗамераВремени");
	ВсеТесты.Добавить("ТестДолжен_ВызватьТестыИзФайлов");
	
	Возврат ВсеТесты;
	
КонецФункции

Процедура ТестДолжен_ПолучитьПутьКOscript() Экспорт
	
	Путь = Новый Файл(ПутьОСкрипт());
	
	юТест.ПроверитьИстину(Путь.Существует());
	
КонецПроцедуры

Функция СтрокаЗапускаОСкрипта(Знач ПутьКИсполняемомуМодулю)

	СИ = Новый СистемнаяИнформация;
	Если Найти(СИ.ВерсияОС, "Windows") > 0 Тогда
		Возврат """" + ПутьКИсполняемомуМодулю + """";
	КонецЕсли;

	Возврат "mono """ + ПутьКИСполняемомуМодулю + """";

КонецФункции

Функция ПолучитьВыводДляТекста(Знач ТекстСкрипта)

	ИмяФайлаОСкрипта = ПолучитьИмяВременногоФайла("os");

	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайлаОСкрипта);
	ЗаписьТекста.Записать(ТекстСкрипта);
	ЗаписьТекста.Закрыть();

	Результат = ПолучитьВыводДляСкрипта(ИмяФайлаОСкрипта);

	УдалитьФайлы(ИмяФайлаОСкрипта);

	Возврат Результат;
	
КонецФункции

Функция ПолучитьВыводДляСкрипта(Знач ИмяФайлаОСкрипта)

	ИмяФайлаВывода = ЗапуститьФайлСкрипта(ИмяФайлаОСкрипта);

	Чтение = Новый ЧтениеJson();
	Чтение.ОткрытьФайл(ИмяФайлаВывода, "UTF-8");

	Результат = ПрочитатьЗначение(Чтение);
	Чтение.Закрыть();

	УдалитьФайлы(ИмяФайлаВывода);
	
	Возврат Результат;
	
КонецФункции

Функция ЗапуститьФайлСкрипта(Знач ИмяФайлаОСкрипта)
	
	Перем ИмяФайла, СтрокаЗапуска;
	ИмяФайлаВывода = ПолучитьИмяВременногоФайла("json");

	Путь = СтрокаЗапускаОСкрипта(ПутьОСкрипт());

	СИ = Новый СистемнаяИнформация;
	Если Найти(СИ.ВерсияОС, "Windows") > 0 Тогда
	
		ИмяФайлаСистемногоСкриптаЗапуска = ПолучитьИмяВременногоФайла("cmd");
		ЗаписьТекста = Новый ЗаписьТекста(ИмяФайлаСистемногоСкриптаЗапуска, КодировкаТекста.Oem);
		ЗаписьТекста.ЗаписатьСтроку("@echo off");
		
		ЗаписьТекста.ЗаписатьСтроку(Путь + " -codestat=" + ИмяФайлаВывода + " " + ИмяФайлаОСкрипта);
		ЗаписьТекста.Закрыть();

		СтрокаЗапуска = ИмяФайлаСистемногоСкриптаЗапуска;

	Иначе
	
		ИмяФайлаСистемногоСкриптаЗапуска = ПолучитьИмяВременногоФайла("sh");
		ЗаписьТекста = Новый ЗаписьТекста(ИмяФайлаСистемногоСкриптаЗапуска,,,, Символы.ПС);
		ЗаписьТекста.ЗаписатьСтроку("bash -s <<<CALLEOF");
		ЗаписьТекста.ЗаписатьСтроку("" 
			+ Путь + " -codestat=" + ИмяФайлаВывода
			+ " " + ИмяФайлаОСкрипта
			+ " > /dev/null"
		);
		ЗаписьТекста.ЗаписатьСтроку("CALLEOF");
		ЗаписьТекста.Закрыть();

		СтрокаЗапуска = "bash " + ИмяФайлаСистемногоСкриптаЗапуска;

	КонецЕсли;
	
	Процесс = СоздатьПроцесс(СтрокаЗапуска,,Истина);
	Процесс.Запустить();

	Процесс.ОжидатьЗавершения();

	УдалитьФайлы(ИмяФайлаСистемногоСкриптаЗапуска);
	
	Возврат ИмяФайлаВывода;

КонецФункции

Функция ПрочитатьЗначение(Знач Чтение)

	Если Не Чтение.Прочитать() Тогда
		ВызватьИсключение "Неверный JSON";
	КонецЕсли;

	Если Чтение.ТипТекущегоЗначения = ТипЗначенияJson.НачалоОбъекта Тогда

		Результат = Новый Соответствие;
		Пока Истина Цикл

			Если Не Чтение.Прочитать() Тогда
				ВызватьИсключение "Неверный JSON"
			КонецЕсли;

			Если Чтение.ТипТекущегоЗначения = ТипЗначенияJson.КонецОбъекта Тогда
				Прервать;
			КонецЕсли;

			Если Чтение.ТипТекущегоЗначения = ТипЗначенияJson.ИмяСвойства Тогда
				
				ИмяСвойства = Чтение.ТекущееЗначение;
				ЗначениеСвойства = ПрочитатьЗначение(Чтение);
				Результат.Вставить(ИмяСвойства, ЗначениеСвойства);

			КонецЕсли;

		КонецЦикла;

		Возврат Результат;

	ИначеЕсли Чтение.ТипТекущегоЗначения = ТипЗначенияJson.НачалоМассива Тогда

		Результат = Новый Массив;
		// Массивов в выводе быть не должно
		Возврат Результат;

	ИначеЕсли Чтение.ТипТекущегоЗначения = ТипЗначенияJson.Null Тогда
		
		Возврат Null;

	ИначеЕсли Чтение.ТипТекущегоЗначения = ТипЗначенияJson.Ничего Тогда

		Возврат Неопределено;

	ИначеЕсли Чтение.ТипТекущегоЗначения = ТипЗначенияJson.Строка Тогда

		Возврат Чтение.ТекущееЗначение;
		
	ИначеЕсли Чтение.ТипТекущегоЗначения = ТипЗначенияJson.Число Тогда

		Возврат Чтение.ТекущееЗначение;
		
	КонецЕсли 

КонецФункции

Функция ПолучитьДанныеПервогоФайла(Знач Данные)
	
	Для Каждого мКЗ Из Данные Цикл
		
		Возврат мКЗ.Значение;

	КонецЦикла;

КонецФункции

Функция ПолучитьОжидаемуюСтатистику(Знач ТекстСкрипта)

	Разделитель = "//-";

	ТаблицаРезультата = Новый ТаблицаЗначений;
	ТаблицаРезультата.Колонки.Добавить("ИмяМетода");
	ТаблицаРезультата.Колонки.Добавить("НомерСтроки");
	ТаблицаРезультата.Колонки.Добавить("Количество");

	ПолныйТекст = Новый ТекстовыйДокумент;
	ПолныйТекст.УстановитьТекст(ТекстСкрипта);

	Для НомерСтроки = 1 По ПолныйТекст.КоличествоСтрок() Цикл

		ТекстСтроки = ПолныйТекст.ПолучитьСтроку(НомерСтроки);
		ПоложениеКлюча = СтрНайти(ТекстСтроки, Разделитель);

		Если ПоложениеКлюча = 0 Тогда
			Продолжить;
		КонецЕсли;

		СтрокаОжидаемогоРезультата = СокрЛП(Сред(ТекстСтроки, ПоложениеКлюча + СтрДлина(Разделитель)));
		ОжидаемыеДанные = СтрРазделить(СтрокаОжидаемогоРезультата, ":");
		Если ОжидаемыеДанные.Количество() < 2 Тогда
			Продолжить;
		КонецЕсли;

		НоваяСтрока = ТаблицаРезультата.Добавить();
		НоваяСтрока.ИмяМетода = ОжидаемыеДанные[0];
		НоваяСтрока.НомерСтроки = НомерСтроки;
		НоваяСтрока.Количество = Число(СокрЛП(ОжидаемыеДанные[1]));

	КонецЦикла;

	Возврат ТаблицаРезультата;

КонецФункции

Процедура ВыполнитьСравнениеСтатистики(Знач ПолученнаяСтатистика, Знач ОжидаемаяСтатистика, Знач ИмяТеста)

	// Из json-а получаем соответствие, но сравнивать удобнее таблицами

	ТаблицаПолученнойСтатистики = ОжидаемаяСтатистика.Скопировать();
	ТаблицаПолученнойСтатистики.Колонки.Добавить("КоличествоПолучено");

	Для Каждого мМетод Из ПолученнаяСтатистика Цикл

		Если Не ТипЗнч(мМетод.Значение) = Тип("Соответствие") Тогда
			Продолжить;
		КонецЕсли;

		Для Каждого мДанныеМетода Из мМетод.Значение Цикл

			НоваяСтрока = ТаблицаПолученнойСтатистики.Добавить();
			НоваяСтрока.ИмяМетода = мМетод.Ключ;
			НоваяСтрока.НомерСтроки = Число(мДанныеМетода.Ключ);
			НоваяСтрока.Количество = -мДанныеМетода.Значение["count"];
			НоваяСтрока.КоличествоПолучено = мДанныеМетода.Значение["count"];

		КонецЦикла;

	КонецЦикла;

	ТаблицаПолученнойСтатистики.Свернуть("ИмяМетода, НомерСтроки", "Количество, КоличествоПолучено");

	Для Каждого мСтрокаПроверки Из ТаблицаПолученнойСтатистики Цикл

		Получили = мСтрокаПроверки.КоличествоПолучено;
		Ожидали = мСтрокаПроверки.Количество + мСтрокаПроверки.КоличествоПолучено;
		ТекстОшибкиСравнения = СтрШаблон("%1: Сравнение для %2, строка %3",
			ИмяТеста, мСтрокаПроверки.ИмяМетода, мСтрокаПроверки.НомерСтроки
		);

		юТест.ПроверитьРавенство(Получили, Ожидали, ТекстОшибкиСравнения);

	КонецЦикла;

КонецПроцедуры

Процедура ТестДолжен_ВызватьТестыИзФайлов() Экспорт

	Файлы = НайтиФайлы("codestat", "*.os");
	Для Каждого мФайл Из Файлы Цикл

		Попытка

			Чтение = Новый ЧтениеТекста;
			Чтение.Открыть(мФайл.ПолноеИмя);
			ТекстСкрипта = Чтение.Прочитать();
			
			Данные = ПолучитьВыводДляСкрипта(мФайл.ПолноеИмя);
			Данные = ПолучитьДанныеПервогоФайла(Данные);

			ОжидаемыеДанные = ПолучитьОжидаемуюСтатистику(ТекстСкрипта);
			ВыполнитьСравнениеСтатистики(Данные, ОжидаемыеДанные, мФайл.ИмяБезРасширения);

		Исключение

			Сообщить(мФайл.ПолноеИмя, СтатусСообщения.Важное);
			ВызватьИсключение;

		КонецПопытки;

	КонецЦикла;

КонецПроцедуры

Процедура ТестДолжен_ПроверитьРаботуЗамераВремени() Экспорт

	ТекстСкрипта = "Sleep(1000);";

	Данные = ПолучитьВыводДляТекста(ТекстСкрипта);
	Данные = ПолучитьДанныеПервогоФайла(Данные);

	юТест.ПроверитьБольшеИлиРавно(Данные["$entry"]["1"]["time"], 1000);
	
КонецПроцедуры

Функция ПутьОСкрипт()
	Возврат ОбъединитьПути(КаталогПрограммы(), "oscript.exe");
КонецФункции

Функция НормализоватьПереводыСтрок(Знач ИсходнаяСтрока)
	Возврат СтрЗаменить(ИсходнаяСтрока, Символы.ВК, "");
КонецФункции
