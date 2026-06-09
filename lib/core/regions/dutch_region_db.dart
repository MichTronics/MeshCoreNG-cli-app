// Generated from MeshWiki "Lijst van regio's" on 2026-05-29.
// Source: https://meshwiki.nl/wiki/Lijst_van_regio%27s

class DutchRegionEntry {
  const DutchRegionEntry({
    required this.index,
    required this.place,
    required this.municipality,
    required this.primaryCode,
    required this.codes,
  });

  final int index;
  final String place;
  final String municipality;
  final String primaryCode;
  final List<String> codes;

  String format() {
    return '[$index] $primaryCode $place ($municipality): ${codes.join(', ')}';
  }
}

class DutchRegionDb {
  const DutchRegionDb._();

  static const entryCount = 2484;
  static const provinceCount = 12;

  static final List<DutchRegionEntry> entries = _parseEntries();

  static String info() {
    return 'Local Dutch region database: $entryCount locations, '
        "$provinceCount provinces. Source: MeshWiki Lijst van regio's.";
  }

  static String provinces() {
    return _provinceData
        .trim()
        .split('\n')
        .map((line) {
          final parts = line.split('\t');
          return '${parts[1]} (${parts[0]}) ${parts[2]}: ${parts[3]} locations';
        })
        .join('\n');
  }

  static String find(String prefix, {int limit = 20}) {
    final query = _normalize(prefix);
    if (query.isEmpty) return 'Usage: regiondb find <name-prefix>';

    final matches = entries.where((entry) {
      return _normalize(entry.place).startsWith(query) ||
          _normalize(entry.municipality).startsWith(query);
    }).take(limit + 1).toList();

    if (matches.isEmpty) return 'No Dutch region matches for "$prefix"';

    final shown = matches.take(limit).map((entry) => entry.format()).toList();
    if (matches.length > limit) {
      shown.add('... more matches; refine your prefix');
    }
    return shown.join('\n');
  }

  static String get(String indexText) {
    final index = int.tryParse(indexText.trim());
    if (index == null) return 'Usage: regiondb get <index>';
    if (index < 0 || index >= entries.length) {
      return 'Dutch region index out of range: $index';
    }
    return entries[index].format();
  }

  static String code(String code) {
    final value = code.trim();
    if (value.isEmpty) return 'Usage: regiondb code <region-code>';
    final matches = entries.where((entry) => entry.codes.contains(value));
    if (matches.isEmpty) return 'No Dutch region entries for code "$value"';
    return matches.take(20).map((entry) => entry.format()).join('\n');
  }

  static String? handleCommand(String command) {
    final trimmed = command.trim();
    final lower = trimmed.toLowerCase();
    if (lower == 'regiondb' || lower == 'regiondb info') return info();
    if (lower == 'regiondb provinces') return provinces();
    if (lower.startsWith('regiondb find ')) {
      return find(trimmed.substring('regiondb find '.length).trim());
    }
    if (lower.startsWith('regiondb get ')) {
      return get(trimmed.substring('regiondb get '.length).trim());
    }
    if (lower.startsWith('regiondb code ')) {
      return code(trimmed.substring('regiondb code '.length).trim());
    }
    if (lower.startsWith('regiondb')) {
      return 'Usage: regiondb info | provinces | find <prefix> | get <index> | code <region-code>';
    }
    return null;
  }

  static List<DutchRegionEntry> _parseEntries() {
    final lines = _entryData.trim().split('\n');
    return [
      for (var i = 0; i < lines.length; i++) _parseEntry(i, lines[i]),
    ];
  }

  static DutchRegionEntry _parseEntry(int index, String line) {
    final parts = line.split('\t');
    return DutchRegionEntry(
      index: index,
      place: parts[0],
      municipality: parts[1],
      primaryCode: parts[2],
      codes: parts[3].split(','),
    );
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}

const _provinceData = r"""
gr	Groningen	nl-gr	197
fr	Friesland	nl-fr	413
dr	Drenthe	nl-dr	225
ov	Overijssel	nl-ov	178
fl	Flevoland	nl-fl	19
ge	Gelderland	nl-ge	330
ut	Utrecht	nl-ut	104
nh	Noord-Holland	nl-nh	238
zh	Zuid-Holland	nl-zh	184
ze	Zeeland	nl-ze	126
nb	Noord-Brabant	nl-nb	279
li	Limburg	nl-li	191
""";

const _entryData = r"""
't Waar	Oldambt	nl-gr-twa	nl,nl-gr,nl-grq,nl-stk,nl-gr-owi,nl-gr-twa
't Zandt	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Adorp	Het Hogeland	nl-gr-les	nl,nl-gr,nl-dr,nl-grq,nl-gr-les
Aduard	Westerkwartier	nl-gr-adu	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui,nl-gr-adu
Alteveer	Stadskanaal	nl-gr-vrt	nl,nl-gr,nl-dr,nl-stk,nl-gr-stk,nl-gr-vrt
Appingedam	Eemsdelta	nl-gr-app	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-app
Bad Nieuweschans	Oldambt	nl-gr-owi	nl,nl-gr,nl-stk,nl-gr-owi
Baflo	Het Hogeland	nl-gr-baf	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-baf
Bedum	Het Hogeland	nl-gr-bed	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-bed
Beerta	Oldambt	nl-gr-owi	nl,nl-gr,nl-stk,nl-gr-owi
Bellingwolde	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-stk,nl-gr-vwd
Bierum	Eemsdelta	nl-gr-bir	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-bir
Blauwestad	Oldambt	nl-gr-owi	nl,nl-gr,nl-stk,nl-gr-owi
Blijham	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-stk,nl-gr-vwd
Boerakker	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui
Borgercompagnie	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-dr,nl-stk,nl-gr-hgz
Borgercompagnie	Veendam	nl-gr-vdm	nl,nl-gr,nl-dr,nl-stk,nl-gr-vdm
Borgsweer	Eemsdelta	nl-gr-bgw	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-bgw
Bourtange	Westerwolde	nl-gr-bta	nl,nl-gr,nl-stk,nl-gr-vwd,nl-gr-bta
Briltil	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui
De Wilp	Westerkwartier	nl-gr-dew	nl,nl-gr,nl-fr,nl-dr,nl-grq,nl-ass,nl-gr-zui,nl-gr-dew
Delfzijl	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-dzl
Den Andel	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Den Ham	Westerkwartier	nl-gr-dhm	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui,nl-gr-dhm
Den Horn	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui
Doezum	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui
Drieborg	Oldambt	nl-gr-db2	nl,nl-gr,nl-stk,nl-gr-owi,nl-gr-db2
Eemshaven	Het Hogeland	nl-gr-eem	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-eem
Eenrum	Het Hogeland	nl-gr-een	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-een
Eenum	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Enumatil	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui
Eppenhuizen	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Ezinge	Westerkwartier	nl-gr-ezi	nl,nl-gr,nl-grq,nl-gr-zui,nl-gr-ezi
Farmsum	Eemsdelta	nl-gr-far	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-far
Feerwerd	Westerkwartier	nl-gr-fee	nl,nl-gr,nl-grq,nl-gr-zui,nl-gr-fee
Finsterwolde	Oldambt	nl-gr-fin	nl,nl-gr,nl-stk,nl-gr-owi,nl-gr-fin
Foxhol	Midden-Groningen	nl-gr-fox	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz,nl-gr-fox
Froombosch	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz
Garmerwolde	Groningen	nl-gr-gwo	nl,nl-gr,nl-grq,nl-gr-grq,nl-gr-gwo
Garnwerd	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-grq,nl-gr-zui
Garrelsweer	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Garsthuizen	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Glimmen	Groningen	nl-gr-grq	nl,nl-gr,nl-dr,nl-grq,nl-gr-grq
Godlinze	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Grijpskerk	Westerkwartier	nl-gr-gri	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-gri
Groningen	Groningen	nl-gr-grq	nl,nl-gr,nl-dr,nl-grq,nl-gr-grq,nl-gr-grq
Grootegast	Westerkwartier	nl-gr-gtg	nl,nl-gr,nl-fr,nl-dr,nl-grq,nl-gr-zui,nl-gr-gtg
Haren Gn	Groningen	nl-gr-grq	nl,nl-gr,nl-dr,nl-grq,nl-gr-grq
Harkstede	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-grq,nl-gr-hgz
Harkstede GN	Groningen	nl-gr-grq	nl,nl-gr,nl-grq,nl-gr-grq
Heiligerlee	Oldambt	nl-gr-hei	nl,nl-gr,nl-stk,nl-gr-owi,nl-gr-hei
Hellum	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-grq,nl-gr-hgz
Holwierde	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Hoogezand	Midden-Groningen	nl-gr-hzd	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz,nl-gr-hzd
Hornhuizen	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Houwerzijl	Het Hogeland	nl-gr-les	nl,nl-gr,nl-fr,nl-grq,nl-gr-les
Huizinge	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Jonkersvaart	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui
Kantens	Het Hogeland	nl-gr-ktn	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-ktn
Kiel-Windeweer	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz
Kloosterburen	Het Hogeland	nl-gr-ktl	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-ktl
Kolham	Midden-Groningen	nl-gr-kha	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz,nl-gr-kha
Kommerzijl	Westerkwartier	nl-gr-kml	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-kml
Kornhorn	Westerkwartier	nl-gr-zan	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-zan
Krewerd	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Kropswolde	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz
Lageland	Midden-Groningen	nl-gr-lgd	nl,nl-gr,nl-grq,nl-gr-hgz,nl-gr-lgd
Lageland GN	Groningen	nl-gr-grq	nl,nl-gr,nl-grq,nl-gr-grq
Lauwersoog	Het Hogeland	nl-gr-lan	nl,nl-gr,nl-fr,nl-grq,nl-gr-les,nl-gr-lan
Lauwerzijl	Westerkwartier	nl-gr-lwi	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-lwi
Leek	Westerkwartier	nl-gr-lee	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui,nl-gr-lee
Leens	Het Hogeland	nl-gr-les	nl,nl-gr,nl-fr,nl-grq,nl-gr-les,nl-gr-les
Leermens	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Lellens	Groningen	nl-gr-grq	nl,nl-gr,nl-grq,nl-gr-grq
Lettelbert	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui
Loppersum	Eemsdelta	nl-gr-lpm	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-lpm
Losdorp	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Lucaswolde	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui
Luddeweer	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-grq,nl-gr-hgz
Lutjegast	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui
Marum	Westerkwartier	nl-gr-mrm	nl,nl-gr,nl-fr,nl-dr,nl-grq,nl-gr-zui,nl-gr-mrm
Meeden	Midden-Groningen	nl-gr-mek	nl,nl-gr,nl-stk,nl-gr-hgz,nl-gr-mek
Meedhuizen	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Meerstad	Groningen	nl-gr-grq	nl,nl-gr,nl-dr,nl-grq,nl-gr-grq
Mensingeweer	Het Hogeland	nl-gr-msw	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-msw
Middelstum	Eemsdelta	nl-gr-mdu	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-mdu
Midwolda	Oldambt	nl-gr-mwd	nl,nl-gr,nl-stk,nl-gr-owi,nl-gr-mwd
Midwolde	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui
Muntendam	Midden-Groningen	nl-gr-mtd	nl,nl-gr,nl-dr,nl-stk,nl-gr-hgz,nl-gr-mtd
Mussel	Stadskanaal	nl-gr-stk	nl,nl-gr,nl-dr,nl-stk,nl-gr-stk
Musselkanaal	Stadskanaal	nl-gr-mus	nl,nl-gr,nl-dr,nl-stk,nl-gr-stk,nl-gr-mus
Niebert	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui
Niehove	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui
Niekerk	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui
Nieuw Beerta	Oldambt	nl-gr-owi	nl,nl-gr,nl-stk,nl-gr-owi
Nieuw Scheemda	Oldambt	nl-gr-owi	nl,nl-gr,nl-stk,nl-grq,nl-gr-owi
Nieuwe Pekela	Pekela	nl-gr-npk	nl,nl-gr,nl-dr,nl-stk,nl-gr-pek,nl-gr-npk
Nieuwolda	Oldambt	nl-gr-nwo	nl,nl-gr,nl-grq,nl-stk,nl-gr-owi,nl-gr-nwo
Niezijl	Westerkwartier	nl-gr-nzi	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-nzi
Noordbroek	Midden-Groningen	nl-gr-eor	nl,nl-gr,nl-grq,nl-gr-hgz,nl-gr-eor
Noordhorn	Westerkwartier	nl-gr-nhr	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui,nl-gr-nhr
Noordlaren	Groningen	nl-gr-grq	nl,nl-gr,nl-dr,nl-grq,nl-gr-grq
Noordwijk	Westerkwartier	nl-gr-ndw	nl,nl-gr,nl-fr,nl-dr,nl-grq,nl-gr-zui,nl-gr-ndw
Noordwolde	Het Hogeland	nl-gr-nwd	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-nwd
Nuis	Westerkwartier	nl-gr-nui	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui,nl-gr-nui
Oldehove	Westerkwartier	nl-gr-ole	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-ole
Oldekerk	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui
Oldenzijl	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Onderdendam	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Onnen	Groningen	nl-gr-grq	nl,nl-gr,nl-dr,nl-grq,nl-gr-grq
Onstwedde	Stadskanaal	nl-gr-stk	nl,nl-gr,nl-dr,nl-stk,nl-gr-stk
Oosternieland	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Oosterwijtwerd	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Oostwold	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui
Opende	Westerkwartier	nl-gr-opg	nl,nl-gr,nl-fr,nl-grq,nl-lwr,nl-gr-zui,nl-gr-opg
Oude Pekela	Pekela	nl-gr-odp	nl,nl-gr,nl-stk,nl-gr-pek,nl-gr-odp
Oudeschans	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-stk,nl-gr-vwd
Oudeschip	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Oudezijl	Oldambt	nl-gr-owi	nl,nl-gr,nl-stk,nl-gr-owi
Overschild	Midden-Groningen	nl-gr-osk	nl,nl-gr,nl-grq,nl-gr-hgz,nl-gr-osk
Pieterburen	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Pieterzijl	Westerkwartier	nl-gr-pzi	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-pzi
Rasquert	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Roodeschool	Het Hogeland	nl-gr-rds	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-rds
Rottum	Het Hogeland	nl-gr-rtu	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-rtu
Saaksum	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui
Saaxumhuizen	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Sappemeer	Midden-Groningen	nl-gr-sap	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz,nl-gr-sap
Sauwerd	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Scharmer	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz
Scheemda	Oldambt	nl-gr-smd	nl,nl-gr,nl-stk,nl-gr-owi,nl-gr-smd
Schildwolde	Midden-Groningen	nl-gr-sdw	nl,nl-gr,nl-grq,nl-gr-hgz,nl-gr-sdw
Schouwerzijl	Het Hogeland	nl-gr-swl	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-swl
Sebaldeburen	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-fr,nl-dr,nl-grq,nl-gr-zui
Sellingen	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-dr,nl-stk,nl-gr-vwd
Siddeburen	Midden-Groningen	nl-gr-sdd	nl,nl-gr,nl-grq,nl-gr-hgz,nl-gr-sdd
Sint Annen	Groningen	nl-gr-grq	nl,nl-gr,nl-grq,nl-gr-grq
Slochteren	Midden-Groningen	nl-gr-slo	nl,nl-gr,nl-grq,nl-gr-hgz,nl-gr-slo
Spijk	Eemsdelta	nl-gr-sjk	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-sjk
Stadskanaal	Stadskanaal	nl-gr-stk	nl,nl-gr,nl-dr,nl-stk,nl-gr-stk,nl-gr-stk
Startenhuizen	Eemsdelta	nl-gr-shn	nl,nl-gr,nl-grq,nl-gr-dzl,nl-gr-shn
Startenhuizen	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Stedum	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Steendam	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-grq,nl-gr-hgz
Stitswerd	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Ten Boer	Groningen	nl-gr-nto	nl,nl-gr,nl-grq,nl-gr-grq,nl-gr-nto
Ten Post	Groningen	nl-gr-tpt	nl,nl-gr,nl-grq,nl-gr-grq,nl-gr-tpt
Ter Apel	Westerwolde	nl-gr-tph	nl,nl-gr,nl-dr,nl-emm,nl-stk,nl-gr-vwd,nl-gr-tph
Ter Apelkanaal	Westerwolde	nl-gr-tak	nl,nl-gr,nl-dr,nl-stk,nl-gr-vwd,nl-gr-tak
Termunten	Eemsdelta	nl-gr-tmn	nl,nl-gr,nl-grq,nl-stk,nl-gr-dzl,nl-gr-tmn
Termunterzijl	Eemsdelta	nl-gr-tmz	nl,nl-gr,nl-grq,nl-stk,nl-gr-dzl,nl-gr-tmz
Thesinge	Groningen	nl-gr-grq	nl,nl-gr,nl-grq,nl-gr-grq
Tinallinge	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Tjuchem	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-grq,nl-gr-hgz
Tolbert	Westerkwartier	nl-gr-tol	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui,nl-gr-tol
Toornwerd	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Tripscompagnie	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-dr,nl-stk,nl-grq,nl-gr-hgz
Uithuizen	Het Hogeland	nl-gr-utz	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-utz
Uithuizermeeden	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Ulrum	Het Hogeland	nl-gr-ulr	nl,nl-gr,nl-fr,nl-grq,nl-gr-les,nl-gr-ulr
Usquert	Het Hogeland	nl-gr-npz	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-npz
Veelerveen	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-stk,nl-gr-vwd
Veendam	Veendam	nl-gr-vdm	nl,nl-gr,nl-dr,nl-stk,nl-gr-vdm,nl-gr-vdm
Vierhuizen	Het Hogeland	nl-gr-vhn	nl,nl-gr,nl-fr,nl-grq,nl-gr-les,nl-gr-vhn
Visvliet	Westerkwartier	nl-gr-vsi	nl,nl-gr,nl-fr,nl-grq,nl-gr-zui,nl-gr-vsi
Vlagtwedde	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-stk,nl-gr-vwd,nl-gr-vwd
Vledderveen	Stadskanaal	nl-gr-stk	nl,nl-gr,nl-dr,nl-stk,nl-gr-stk
Vriescheloo	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-stk,nl-gr-vwd
Wagenborgen	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Warffum	Het Hogeland	nl-gr-wfm	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-wfm
Warfhuizen	Het Hogeland	nl-gr-whu	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-whu
Waterhuizen	Midden-Groningen	nl-gr-whz	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz,nl-gr-whz
Wedde	Westerwolde	nl-gr-vwd	nl,nl-gr,nl-stk,nl-gr-vwd
Wehe-den Hoorn	Het Hogeland	nl-gr-who	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-who
Westerbroek	Midden-Groningen	nl-gr-wbr	nl,nl-gr,nl-dr,nl-grq,nl-gr-hgz,nl-gr-wbr
Westeremden	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Westerlee	Oldambt	nl-gr-g7r	nl,nl-gr,nl-stk,nl-gr-owi,nl-gr-g7r
Westernieland	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Westerwijtwerd	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Wetsinge	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Wildervank	Veendam	nl-gr-wld	nl,nl-gr,nl-dr,nl-stk,nl-gr-vdm,nl-gr-wld
Winneweer	Groningen	nl-gr-grq	nl,nl-gr,nl-grq,nl-gr-grq
Winschoten	Oldambt	nl-gr-wsc	nl,nl-gr,nl-stk,nl-gr-owi,nl-gr-wsc
Winsum	Het Hogeland	nl-gr-wns	nl,nl-gr,nl-grq,nl-gr-les,nl-gr-wns
Wirdum	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Woldendorp	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-stk,nl-gr-dzl
Woltersum	Groningen	nl-gr-grq	nl,nl-gr,nl-grq,nl-gr-grq
Woudbloem	Midden-Groningen	nl-gr-hgz	nl,nl-gr,nl-grq,nl-gr-hgz
Zandeweer	Het Hogeland	nl-gr-les	nl,nl-gr,nl-grq,nl-gr-les
Zeerijp	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Zevenhuizen	Westerkwartier	nl-gr-zvh	nl,nl-gr,nl-dr,nl-fr,nl-grq,nl-gr-zui,nl-gr-zvh
Zijldijk	Eemsdelta	nl-gr-dzl	nl,nl-gr,nl-grq,nl-gr-dzl
Zoutkamp	Het Hogeland	nl-gr-zot	nl,nl-gr,nl-fr,nl-grq,nl-gr-les,nl-gr-zot
Zuidbroek	Midden-Groningen	nl-gr-zbo	nl,nl-gr,nl-stk,nl-grq,nl-gr-hgz,nl-gr-zbo
Zuidhorn	Westerkwartier	nl-gr-zui	nl,nl-gr,nl-dr,nl-grq,nl-gr-zui,nl-gr-zui
Zuidwolde	Het Hogeland	nl-gr-zwl	nl,nl-gr,nl-dr,nl-grq,nl-gr-les,nl-gr-zwl
Zuurdijk	Het Hogeland	nl-gr-zuu	nl,nl-gr,nl-fr,nl-grq,nl-gr-les,nl-gr-zuu
Aalsum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Abbega	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk
Achlum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Akkrum	Heerenveen	nl-fr-akr	nl,nl-fr,nl-hrv,nl-fr-hrv,nl-fr-akr
Akmarijp	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Alde Leie	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Aldeboarn	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Aldtsjerk	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Aldwâld	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok
Allingawier	Súdwest-Fryslân	nl-fr-alw	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-alw
Appelscha	Ooststellingwerf	nl-fr-aps	nl,nl-fr,nl-dr,nl-ass,nl-fr-ool,nl-fr-aps
Arum	Súdwest-Fryslân	nl-fr-aru	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-aru
Augsbuurt	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Augustinusga	Achtkarspelen	nl-fr-zac	nl,nl-fr,nl-gr,nl-lwr,nl-grq,nl-fr-ack,nl-fr-zac
Baaiduinen	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Baaium	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Baard	Leeuwarden	nl-fr-ard	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-ard
Bakhuizen	De Fryske Marren	nl-fr-bkh	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-bkh
Bakkeveen	Opsterland	nl-fr-out	nl,nl-fr,nl-gr,nl-dr,nl-ass,nl-fr-out
Balk	De Fryske Marren	nl-fr-bal	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-bal
Ballum	Ameland	nl-fr-aml	nl,nl-fr,nl-hrn,nl-fr-aml
Bantega	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-ov,nl-fl,nl-hrv,nl-fr-dfm
Bears	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Beetsterzwaag	Opsterland	nl-fr-bez	nl,nl-fr,nl-hrv,nl-fr-out,nl-fr-bez
Berltsum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Bitgum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Bitgummole	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Blauwhuis	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Blesdijke	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Blessum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Blije	Noardeast-Fryslân	nl-fr-bli	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-bli
Boazum	Súdwest-Fryslân	nl-fr-boa	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-boa
Boelenslaan	Achtkarspelen	nl-fr-ack	nl,nl-fr,nl-gr,nl-lwr,nl-fr-ack
Boer	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Boijl	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-dr,nl-ov,nl-hrv,nl-fr-wsw
Boksum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Bolsward	Súdwest-Fryslân	nl-fr-bol	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-bol
Bontebok	Heerenveen	nl-fr-bok	nl,nl-fr,nl-hrv,nl-fr-hrv,nl-fr-bok
Boornbergum	Smallingerland	nl-fr-sml	nl,nl-fr,nl-hrv,nl-fr-sml
Boornzwaag	De Fryske Marren	nl-fr-bzw	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-bzw
Bornwird	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Brantgum	Noardeast-Fryslân	nl-fr-btg	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-btg
Breezanddijk	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrn,nl-lwr,nl-hhw,nl-fr-snk
Britsum	Leeuwarden	nl-fr-brt	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-brt
Britswert	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Broek	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Broeksterwâld	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Buitenpost	Achtkarspelen	nl-fr-bui	nl,nl-fr,nl-gr,nl-lwr,nl-fr-ack,nl-fr-bui
Burdaard	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Burgum	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Burgwerd	Súdwest-Fryslân	nl-fr-bwe	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-bwe
Burum	Noardeast-Fryslân	nl-fr-buu	nl,nl-fr,nl-gr,nl-grq,nl-fr-dok,nl-fr-buu
Cornwerd	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Damwâld	Dantumadiel	nl-fr-dam	nl,nl-fr,nl-lwr,nl-fr-dtu,nl-fr-dam
De Blesse	Weststellingwerf	nl-fr-bls	nl,nl-fr,nl-ov,nl-dr,nl-hrv,nl-fr-wsw,nl-fr-bls
De Falom	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
De Hoeve	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-dr,nl-ov,nl-hrv,nl-fr-wsw
De Knipe	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
De Tike	Smallingerland	nl-fr-sml	nl,nl-fr,nl-lwr,nl-fr-sml
De Trieme	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
De Veenhoop	Smallingerland	nl-fr-sml	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-sml
De Westereen	Dantumadiel	nl-fr-dws	nl,nl-fr,nl-lwr,nl-fr-dtu,nl-fr-dws
De Wilgen	Smallingerland	nl-fr-dwg	nl,nl-fr,nl-hrv,nl-fr-sml,nl-fr-dwg
Dearsum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Dedgum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Deinum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Delfstrahuizen	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-ov,nl-hrv,nl-fr-dfm
Dijken	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Dokkum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-dok
Dongjum	Waadhoeke	nl-fr-dnu	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-dnu
Doniaga	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Donkerbroek	Ooststellingwerf	nl-fr-dno	nl,nl-fr,nl-dr,nl-hrv,nl-ass,nl-fr-ool,nl-fr-dno
Drachten	Smallingerland	nl-fr-dra	nl,nl-fr,nl-gr,nl-hrv,nl-fr-sml,nl-fr-dra
Drachten-Azeven	Opsterland	nl-fr-out	nl,nl-fr,nl-gr,nl-hrv,nl-fr-out
Drachtstercompagnie	Smallingerland	nl-fr-sml	nl,nl-fr,nl-gr,nl-hrv,nl-lwr,nl-fr-sml
Driezum	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Drogeham	Achtkarspelen	nl-fr-ack	nl,nl-fr,nl-gr,nl-lwr,nl-fr-ack
Dronryp	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Eagum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Eanjum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok
Earnewâld	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Easterein	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Easterlittens	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Eastermar	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-gr,nl-lwr,nl-fr-bgu
Easternijtsjerk	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Easterwierrum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Echten	De Fryske Marren	nl-fr-etn	nl,nl-fr,nl-ov,nl-fl,nl-hrv,nl-fr-dfm,nl-fr-etn
Echtenerbrug	De Fryske Marren	nl-fr-ehu	nl,nl-fr,nl-ov,nl-hrv,nl-fr-dfm,nl-fr-ehu
Eesterga	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-fl,nl-hrv,nl-fr-dfm
Elahuizen	De Fryske Marren	nl-fr-ela	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-ela
Elsloo	Ooststellingwerf	nl-fr-elo	nl,nl-fr,nl-dr,nl-hrv,nl-ass,nl-fr-ool,nl-fr-elo
Exmorra	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Feanwâlden	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Feanwâlden	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Feinsum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Ferwert	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Ferwoude	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Firdgum	Waadhoeke	nl-fr-fgm	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-fgm
Fochteloo	Ooststellingwerf	nl-fr-ool	nl,nl-fr,nl-dr,nl-ass,nl-fr-ool
Follega	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-fl,nl-hrv,nl-fr-dfm
Folsgare	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Formerum	Terschelling	nl-fr-for	nl,nl-fr,nl-hrn,nl-fr-tsl,nl-fr-for
Foudgum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Franeker	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-frk
Friens	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Frieschepalen	Opsterland	nl-fr-out	nl,nl-fr,nl-gr,nl-dr,nl-hrv,nl-ass,nl-grq,nl-fr-out
Gaast	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Gaastmeer	Súdwest-Fryslân	nl-fr-gme	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-gme
Garyp	Tytsjerksteradiel	nl-fr-grp	nl,nl-fr,nl-lwr,nl-fr-bgu,nl-fr-grp
Gauw	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Gerkesklooster	Achtkarspelen	nl-fr-ack	nl,nl-fr,nl-gr,nl-grq,nl-fr-ack
Gersloot	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Ginnum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Goingarijp	De Fryske Marren	nl-fr-goj	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-goj
Gorredijk	Opsterland	nl-fr-djj	nl,nl-fr,nl-hrv,nl-fr-out,nl-fr-djj
Goutum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Goënga	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Goëngahuizen	Smallingerland	nl-fr-sml	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-sml
Greonterp	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Grou	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Gytsjerk	Tytsjerksteradiel	nl-fr-gjk	nl,nl-fr,nl-lwr,nl-fr-bgu,nl-fr-gjk
Hallum	Noardeast-Fryslân	nl-fr-hll	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-hll
Hantum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Hantumerútbuorren	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Hantumhuzen	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Harich	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Harkema	Achtkarspelen	nl-fr-ack	nl,nl-fr,nl-gr,nl-lwr,nl-fr-ack
Harlingen	Harlingen	nl-fr-har	nl,nl-fr,nl-hrn,nl-lwr,nl-fr-har,nl-fr-har
Hartwerd	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Haskerdijken	Heerenveen	nl-fr-hkd	nl,nl-fr,nl-hrv,nl-fr-hrv,nl-fr-hkd
Haskerhorne	De Fryske Marren	nl-fr-hkr	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-hkr
Haule	Ooststellingwerf	nl-fr-hab	nl,nl-fr,nl-dr,nl-gr,nl-ass,nl-fr-ool,nl-fr-hab
Haulerwijk	Ooststellingwerf	nl-fr-hau	nl,nl-fr,nl-dr,nl-gr,nl-ass,nl-fr-ool,nl-fr-hau
Hee	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Heeg	Súdwest-Fryslân	nl-fr-heg	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-heg
Heerenveen	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv,nl-fr-hrv
Hegebeintum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Hemelum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Hempens	Leeuwarden	nl-fr-hpe	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-hpe
Hemrik	Opsterland	nl-fr-hri	nl,nl-fr,nl-hrv,nl-fr-out,nl-fr-hri
Herbaijum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Hiaure	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Hichtum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Hidaard	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Hieslum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Hijum	Leeuwarden	nl-fr-hjm	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-hjm
Hilaard	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Hindeloopen	Súdwest-Fryslân	nl-fr-hlp	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk,nl-fr-hlp
Hinnaard	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Hitzum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Hollum	Ameland	nl-fr-aml	nl,nl-fr,nl-hrn,nl-fr-aml
Holwert	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Hommerts	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Hoorn	Terschelling	nl-fr-hrn	nl,nl-fr,nl-hrn,nl-fr-tsl,nl-fr-hrn
Hoornsterzwaag	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-dr,nl-hrv,nl-fr-hrv
Houtigehage	Smallingerland	nl-fr-sml	nl,nl-fr,nl-gr,nl-lwr,nl-hrv,nl-fr-sml
Hurdegaryp	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Húns	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Idaerd	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Idsegahuizum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Idskenhuizen	De Fryske Marren	nl-fr-ids	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-ids
Idzega	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Ie	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Iens	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
IJlst	Súdwest-Fryslân	nl-fr-jst	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-jst
Indijk	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Ingelum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Ingwierrum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok
It Heidenskip	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Itens	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Jannum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Jellum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Jelsum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Jirnsum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Jislum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Jistrum	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-gr,nl-lwr,nl-fr-bgu
Jonkerslân	Opsterland	nl-fr-out	nl,nl-fr,nl-hrv,nl-fr-out
Jorwert	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Joure	De Fryske Marren	nl-fr-jou	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-jou
Jouswier	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Jubbega	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Jutrijp	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Kaard	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Katlijk	Heerenveen	nl-fr-ktj	nl,nl-fr,nl-hrv,nl-fr-hrv,nl-fr-ktj
Kimswerd	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Kinnum	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Klooster Lidlum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Koarnjum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Kolderwolde	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Kollum	Noardeast-Fryslân	nl-fr-klm	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok,nl-fr-klm
Kollumerpomp	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-grq,nl-lwr,nl-fr-dok
Kollumersweach	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Kootstertille	Achtkarspelen	nl-fr-zbb	nl,nl-fr,nl-gr,nl-lwr,nl-fr-ack,nl-fr-zbb
Kornwerderzand	Súdwest-Fryslân	nl-fr-kwz	nl,nl-fr,nl-lwr,nl-hrn,nl-fr-snk,nl-fr-kwz
Kortehemmen	Smallingerland	nl-fr-khm	nl,nl-fr,nl-hrv,nl-fr-sml,nl-fr-khm
Koudum	Súdwest-Fryslân	nl-fr-kdm	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-kdm
Koufurderrige	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Kûbaard	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Landerum	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Langedijke	Ooststellingwerf	nl-fr-ool	nl,nl-fr,nl-dr,nl-ass,nl-fr-ool
Langelille	Weststellingwerf	nl-fr-lgi	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw,nl-fr-lgi
Langezwaag	Opsterland	nl-fr-lzg	nl,nl-fr,nl-hrv,nl-fr-out,nl-fr-lzg
Langweer	De Fryske Marren	nl-fr-lgw	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-lgw
Leeuwarden	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-lwr
Legemeer	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Lekkum	Leeuwarden	nl-fr-lkk	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-lkk
Lemmer	De Fryske Marren	nl-fr-lmr	nl,nl-fr,nl-fl,nl-hrv,nl-fr-dfm,nl-fr-lmr
Leons	Leeuwarden	nl-fr-leo	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-leo
Lichtaard	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Lies	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Lippenhuizen	Opsterland	nl-fr-out	nl,nl-fr,nl-hrv,nl-fr-out
Ljussens	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok
Lollum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Longerhouw	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Loënga	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Luinjeberd	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Luxwoude	Opsterland	nl-fr-out	nl,nl-fr,nl-hrv,nl-fr-out
Lytsewierrum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Makkinga	Ooststellingwerf	nl-fr-mkg	nl,nl-fr,nl-dr,nl-hrv,nl-fr-ool,nl-fr-mkg
Makkum	Súdwest-Fryslân	nl-fr-mak	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-mak
Mantgum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Marrum	Noardeast-Fryslân	nl-fr-mrr	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-mrr
Marsum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Menaam	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Midlum	Harlingen	nl-fr-har	nl,nl-fr,nl-lwr,nl-hrn,nl-fr-har
Midsland	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Miedum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Mildam	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Minnertsga	Waadhoeke	nl-fr-m9g	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-m9g
Mirns	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Mitselwier	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Moarre	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok
Moddergat	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok
Molkwerum	Súdwest-Fryslân	nl-fr-mwu	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-mwu
Munnekeburen	Weststellingwerf	nl-fr-mke	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw,nl-fr-mke
Munnekezijl	Noardeast-Fryslân	nl-fr-mkz	nl,nl-fr,nl-gr,nl-grq,nl-fr-dok,nl-fr-mkz
Mûnein	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Nes	Noardeast-Fryslân	nl-fr-nes	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-nes
Nieuwebrug	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Nieuwehorne	Heerenveen	nl-fr-nhm	nl,nl-fr,nl-hrv,nl-fr-hrv,nl-fr-nhm
Nieuweschoot	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Nij Altoenae	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Nij Beets	Opsterland	nl-fr-out	nl,nl-fr,nl-hrv,nl-fr-out
Nijeberkoop	Ooststellingwerf	nl-fr-ool	nl,nl-fr,nl-dr,nl-hrv,nl-fr-ool
Nijega	Smallingerland	nl-fr-nga	nl,nl-fr,nl-lwr,nl-fr-sml,nl-fr-nga
Nijehaske	De Fryske Marren	nl-fr-nhe	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-nhe
Nijeholtpade	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-dr,nl-ov,nl-hrv,nl-fr-wsw
Nijeholtwolde	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Nijelamer	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Nijemirdum	De Fryske Marren	nl-fr-nmd	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-nmd
Nijetrijne	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Nijewier	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Nijhuizum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk
Nijland	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Noardburgum	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Noordwolde	Weststellingwerf	nl-fr-nwd	nl,nl-fr,nl-dr,nl-ov,nl-hrv,nl-fr-wsw,nl-fr-nwd
Oentsjerk	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Offingawier	Súdwest-Fryslân	nl-fr-ogw	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-ogw
Oldeberkoop	Ooststellingwerf	nl-fr-old	nl,nl-fr,nl-dr,nl-hrv,nl-fr-ool,nl-fr-old
Oldeholtpade	Weststellingwerf	nl-fr-odd	nl,nl-fr,nl-ov,nl-dr,nl-hrv,nl-fr-wsw,nl-fr-odd
Oldeholtwolde	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Oldelamer	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Oldeouwer	De Fryske Marren	nl-fr-owe	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-owe
Oldetrijne	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Olterterp	Opsterland	nl-fr-out	nl,nl-fr,nl-hrv,nl-fr-out
Oosterbierum	Waadhoeke	nl-fr-osm	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-osm
Oosterend	Terschelling	nl-fr-ood	nl,nl-fr,nl-hrn,nl-fr-tsl,nl-fr-ood
Oosterstreek	Weststellingwerf	nl-fr-otk	nl,nl-fr,nl-dr,nl-ov,nl-hrv,nl-fr-wsw,nl-fr-otk
Oosterwolde	Ooststellingwerf	nl-fr-osw	nl,nl-fr,nl-dr,nl-ass,nl-fr-ool,nl-fr-osw
Oosterzee	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-fl,nl-hrv,nl-fr-dfm
Oosthem	Súdwest-Fryslân	nl-fr-ohm	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk,nl-fr-ohm
Opeinde	Smallingerland	nl-fr-ope	nl,nl-fr,nl-gr,nl-lwr,nl-fr-sml,nl-fr-ope
Oppenhuizen	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Oranjewoud	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Oudebildtzijl	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Oudega	De Fryske Marren	nl-fr-oga	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-oga
Oudehaske	De Fryske Marren	nl-fr-ohe	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-ohe
Oudehorne	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Oudemirdum	De Fryske Marren	nl-fr-omr	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-omr
Oudeschoot	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Ouwster-Nijega	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Ouwsterhaule	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Parrega	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Peazens	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-lwr,nl-fr-dok
Peins	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Peperga	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-dr,nl-hrv,nl-fr-wsw
Piaam	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Pietersbierum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-hrn,nl-fr-frk
Pingjum	Súdwest-Fryslân	nl-fr-zbn	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-zbn
Poppenwier	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Raard	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Raerd	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Ravenswoud	Ooststellingwerf	nl-fr-ool	nl,nl-fr,nl-dr,nl-ass,nl-fr-ool
Readtsjerk	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Reahûs	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Reduzum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Reitsum	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Ried	Waadhoeke	nl-fr-red	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-red
Rien	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Rijs	De Fryske Marren	nl-fr-rij	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-rij
Rinsumageast	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Rohel	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Rotstergaast	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Rotsterhaule	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Rottevalle	Smallingerland	nl-fr-sml	nl,nl-fr,nl-gr,nl-lwr,nl-fr-sml
Rottum	De Fryske Marren	nl-fr-rtu	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-rtu
Ruigahuizen	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Ryptsjerk	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Sandfirden	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk
Schalsum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Scharnegoutum	Súdwest-Fryslân	nl-fr-sfr	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-sfr
Scharsterbrug	De Fryske Marren	nl-fr-sbg	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-sbg
Scherpenzeel	Weststellingwerf	nl-fr-srp	nl,nl-fr,nl-ov,nl-fl,nl-hrv,nl-fr-wsw,nl-fr-srp
Schettens	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Schiermonnikoog	Schiermonnikoog	nl-fr-smo	nl,nl-fr,nl-gr,nl-lwr,nl-grq,nl-fr-smo,nl-fr-smo
Schraard	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Sexbierum	Waadhoeke	nl-fr-sbm	nl,nl-fr,nl-lwr,nl-hrn,nl-fr-frk,nl-fr-sbm
Sibrandabuorren	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Sibrandahûs	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Siegerswoude	Opsterland	nl-fr-out	nl,nl-fr,nl-gr,nl-dr,nl-hrv,nl-ass,nl-fr-out
Sint Nicolaasga	De Fryske Marren	nl-fr-sng	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-sng
Sintjohannesga	De Fryske Marren	nl-fr-sjo	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-sjo
Skingen	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Slappeterp	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Slijkenburg	Weststellingwerf	nl-fr-skg	nl,nl-fr,nl-ov,nl-fl,nl-hrv,nl-fr-wsw,nl-fr-skg
Sloten	De Fryske Marren	nl-fr-slt	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-slt
Smalle Ee	Smallingerland	nl-fr-sml	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-sml
Smallebrugge	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Snakkerburen	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Sneek	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk,nl-fr-snk
Snikzwaag	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Sondel	De Fryske Marren	nl-fr-sod	nl,nl-fr,nl-fl,nl-hrv,nl-fr-dfm,nl-fr-sod
Sonnega	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw
Spanga	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-fl,nl-hrv,nl-fr-wsw
Spannum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
St.-Annaparochie	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
St.-Jacobiparochie	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Stavoren	Súdwest-Fryslân	nl-fr-sta	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-sta
Steggerda	Weststellingwerf	nl-fr-stg	nl,nl-fr,nl-ov,nl-dr,nl-hrv,nl-fr-wsw,nl-fr-stg
Stiens	Leeuwarden	nl-fr-stn	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-stn
Striep	Terschelling	nl-fr-tsl	nl,nl-fr,nl-hrn,nl-fr-tsl
Stroobos	Achtkarspelen	nl-fr-sts	nl,nl-fr,nl-gr,nl-grq,nl-fr-ack,nl-fr-sts
Sumar	Tytsjerksteradiel	nl-fr-smr	nl,nl-fr,nl-lwr,nl-fr-bgu,nl-fr-smr
Surhuisterveen	Achtkarspelen	nl-fr-sur	nl,nl-fr,nl-gr,nl-lwr,nl-grq,nl-fr-ack,nl-fr-sur
Surhuizum	Achtkarspelen	nl-fr-ack	nl,nl-fr,nl-gr,nl-lwr,nl-grq,nl-fr-ack
Suwâld	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Sweagerbosk	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Swichum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Teerns	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Ter Idzard	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-ov,nl-dr,nl-hrv,nl-fr-wsw
Terband	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Terherne	De Fryske Marren	nl-fr-trh	nl,nl-fr,nl-hrv,nl-fr-dfm,nl-fr-trh
Terkaple	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Ternaard	Noardeast-Fryslân	nl-fr-tnd	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-tnd
Teroele	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Tersoal	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Terwispel	Opsterland	nl-fr-tri	nl,nl-fr,nl-hrv,nl-fr-out,nl-fr-tri
Tijnje	Opsterland	nl-fr-fr5	nl,nl-fr,nl-hrv,nl-fr-out,nl-fr-fr5
Tirns	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Tjalhuizum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Tjalleberd	Heerenveen	nl-fr-hrv	nl,nl-fr,nl-hrv,nl-fr-hrv
Tjerkgaast	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Tjerkwerd	Súdwest-Fryslân	nl-fr-tkw	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-tkw
Twijzel	Achtkarspelen	nl-fr-twy	nl,nl-fr,nl-gr,nl-lwr,nl-fr-ack,nl-fr-twy
Twijzelerheide	Achtkarspelen	nl-fr-twi	nl,nl-fr,nl-lwr,nl-fr-ack,nl-fr-twi
Tytsjerk	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Tzum	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Tzummarum	Waadhoeke	nl-fr-tzu	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-tzu
Uitwellingerga	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Ureterp	Opsterland	nl-fr-ure	nl,nl-fr,nl-gr,nl-hrv,nl-fr-out,nl-fr-ure
Vegelinsoord	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Vinkega	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-dr,nl-ov,nl-hrv,nl-fr-wsw
Vlieland	Vlieland	nl-fr-vll	nl,nl-fr,nl-hrn,nl-fr-vll,nl-fr-vll
Vrouwenparochie	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Waaksens	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Waaxens	Noardeast-Fryslân	nl-fr-wxn	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-wxn
Warfstermolen	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-gr,nl-grq,nl-fr-dok
Warns	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Warstiens	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Warten	Leeuwarden	nl-fr-wtn	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-wtn
Waskemeer	Ooststellingwerf	nl-fr-ool	nl,nl-fr,nl-dr,nl-gr,nl-ass,nl-fr-ool
Weidum	Leeuwarden	nl-fr-wdm	nl,nl-fr,nl-lwr,nl-fr-lwr,nl-fr-wdm
Wergea	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
West-Terschelling	Terschelling	nl-fr-wte	nl,nl-fr,nl-hrn,nl-fr-tsl,nl-fr-wte
Westergeast	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Westhem	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk
Westhoek	Waadhoeke	nl-fr-whk	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-whk
Wetsens	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Wier	Waadhoeke	nl-fr-wie	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-wie
Wierum	Noardeast-Fryslân	nl-fr-wru	nl,nl-fr,nl-lwr,nl-fr-dok,nl-fr-wru
Wijckel	De Fryske Marren	nl-fr-dfm	nl,nl-fr,nl-hrv,nl-fr-dfm
Wijnaldum	Harlingen	nl-fr-wnd	nl,nl-fr,nl-lwr,nl-hrn,nl-fr-har,nl-fr-wnd
Wijnjewoude	Opsterland	nl-fr-wjw	nl,nl-fr,nl-gr,nl-dr,nl-hrv,nl-fr-out,nl-fr-wjw
Winsum	Waadhoeke	nl-fr-wsu	nl,nl-fr,nl-lwr,nl-fr-frk,nl-fr-wsu
Wirdum	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Witmarsum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Wiuwert	Súdwest-Fryslân	nl-fr-wiu	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-wiu
Wjelsryp	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
Wolsum	Súdwest-Fryslân	nl-fr-wlm	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-wlm
Wolvega	Weststellingwerf	nl-fr-wvg	nl,nl-fr,nl-ov,nl-hrv,nl-fr-wsw,nl-fr-wvg
Wommels	Súdwest-Fryslân	nl-fr-wms	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-wms
Wons	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-fr-snk
Workum	Súdwest-Fryslân	nl-fr-wku	nl,nl-fr,nl-hrv,nl-lwr,nl-fr-snk,nl-fr-wku
Woudsend	Súdwest-Fryslân	nl-fr-wsd	nl,nl-fr,nl-hrv,nl-fr-snk,nl-fr-wsd
Wyns	Tytsjerksteradiel	nl-fr-bgu	nl,nl-fr,nl-lwr,nl-fr-bgu
Wytgaard	Leeuwarden	nl-fr-lwr	nl,nl-fr,nl-lwr,nl-fr-lwr
Wâlterswâld	Dantumadiel	nl-fr-dtu	nl,nl-fr,nl-lwr,nl-fr-dtu
Wânswert	Noardeast-Fryslân	nl-fr-dok	nl,nl-fr,nl-lwr,nl-fr-dok
Ypecolsga	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-hrv,nl-fr-snk
Ysbrechtum	Súdwest-Fryslân	nl-fr-snk	nl,nl-fr,nl-lwr,nl-hrv,nl-fr-snk
Zandhuizen	Weststellingwerf	nl-fr-wsw	nl,nl-fr,nl-dr,nl-ov,nl-hrv,nl-fr-wsw
Zurich	Súdwest-Fryslân	nl-fr-zur	nl,nl-fr,nl-lwr,nl-fr-snk,nl-fr-zur
Zweins	Waadhoeke	nl-fr-frk	nl,nl-fr,nl-lwr,nl-fr-frk
't Haantje	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
1e Exloërmond	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-dr-boo
2e Exloërmond	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-emm,nl-dr-boo
2e Valthermond	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-emm,nl-dr-boo
Aalden	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Alteveer	De Wolden	nl-dr-5rd	nl,nl-dr,nl-ov,nl-emm,nl-zwo,nl-dr-wod,nl-dr-5rd
Alteveer gem Hoogeveen	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ov,nl-emm,nl-dr-hov
Amen	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Anderen	Aa en Hunze	nl-dr-and	nl,nl-dr,nl-ass,nl-dr-aah,nl-dr-and
Anloo	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-ass,nl-dr-aah
Annen	Aa en Hunze	nl-dr-nne	nl,nl-dr,nl-gr,nl-ass,nl-dr-aah,nl-dr-nne
Annerveenschekanaal	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah
Ansen	Westerveld	nl-dr-wtv	nl,nl-dr,nl-ass,nl-dr-wtv
Ansen	De Wolden	nl-dr-wod	nl,nl-dr,nl-ass,nl-dr-wod
Assen	Assen	nl-dr-ass	nl,nl-dr,nl-ass,nl-dr-ass,nl-dr-ass
Balinge	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-emm,nl-dr-mdd
Balloo	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Balloërveld	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Barger-Compascuum	Emmen	nl-dr-emm	nl,nl-dr,nl-emm,nl-dr-emm
Beilen	Midden-Drenthe	nl-dr-bei	nl,nl-dr,nl-ass,nl-dr-mdd,nl-dr-bei
Benneveld	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Borger	Borger-Odoorn	nl-dr-bgr	nl,nl-dr,nl-stk,nl-dr-boo,nl-dr-bgr
Boschoord	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ov,nl-hrv,nl-dr-wtv
Bovensmilde	Midden-Drenthe	nl-dr-bvi	nl,nl-dr,nl-fr,nl-ass,nl-dr-mdd,nl-dr-bvi
Broekhuizen	Meppel	nl-dr-mep	nl,nl-dr,nl-ov,nl-zwo,nl-dr-mep
Bronneger	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-stk,nl-dr-boo
Bronnegerveen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-dr-boo
Bruntinge	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-emm,nl-dr-mdd
Buinen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-stk,nl-dr-boo
Buinerveen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-dr-boo
Bunne	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-grq,nl-ass,nl-dr-tno
Coevorden	Coevorden	nl-dr-coe	nl,nl-dr,nl-ov,nl-emm,nl-dr-coe,nl-dr-coe
Dalen	Coevorden	nl-dr-tre	nl,nl-dr,nl-ov,nl-emm,nl-dr-coe,nl-dr-tre
Dalerpeel	Coevorden	nl-dr-coe	nl,nl-dr,nl-ov,nl-emm,nl-dr-coe
Dalerveen	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Darp	Westerveld	nl-dr-wtv	nl,nl-dr,nl-ov,nl-hrv,nl-dr-wtv
De Groeve	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-grq,nl-dr-tno
De Kiel	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
De Punt	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-grq,nl-ass,nl-dr-tno
De Schiphorst	Meppel	nl-dr-mep	nl,nl-dr,nl-ov,nl-zwo,nl-dr-mep
de Wijk	De Wolden	nl-dr-dwk	nl,nl-dr,nl-ov,nl-zwo,nl-dr-wod,nl-dr-dwk
Deurze	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Diever	Westerveld	nl-dr-die	nl,nl-dr,nl-fr,nl-ass,nl-dr-wtv,nl-dr-die
Dieverbrug	Westerveld	nl-dr-dvb	nl,nl-dr,nl-ass,nl-dr-wtv,nl-dr-dvb
Diphoorn	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Doldersum	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ov,nl-hrv,nl-ass,nl-dr-wtv
Donderen	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-ass,nl-grq,nl-dr-tno
Drijber	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-emm,nl-dr-mdd
Drogteropslagen	De Wolden	nl-dr-wod	nl,nl-dr,nl-ov,nl-zwo,nl-alm,nl-emm,nl-dr-wod
Drouwen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-stk,nl-dr-boo
Drouwenermond	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-dr-boo
Drouwenerveen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-dr-boo
Dwingeloo	Westerveld	nl-dr-dwi	nl,nl-dr,nl-ass,nl-dr-wtv,nl-dr-dwi
Echten	De Wolden	nl-dr-etn	nl,nl-dr,nl-ov,nl-zwo,nl-ass,nl-dr-wod,nl-dr-etn
Eelde	Tynaarlo	nl-dr-lde	nl,nl-dr,nl-gr,nl-grq,nl-dr-tno,nl-dr-lde
Eelderwolde	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-grq,nl-dr-tno
Een	Noordenveld	nl-dr-nov	nl,nl-dr,nl-fr,nl-gr,nl-ass,nl-dr-nov
Een-West	Noordenveld	nl-dr-nov	nl,nl-dr,nl-fr,nl-gr,nl-ass,nl-dr-nov
Ees	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-stk,nl-emm,nl-dr-boo
Eesergroen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-dr-boo
Eeserveen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-dr-boo
Eext	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Eexterveen	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah
Eexterveenschekanaal	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah
Eexterzandvoort	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah
Ekehaar	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Eldersloo	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Eleveld	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Elim	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ov,nl-emm,nl-dr-hov
Ellertshaar	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-ass,nl-dr-boo
Elp	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-dr-mdd
Emmen	Emmen	nl-dr-emm	nl,nl-dr,nl-emm,nl-dr-emm,nl-dr-emm
Emmer-Compascuum	Emmen	nl-dr-emc	nl,nl-dr,nl-gr,nl-emm,nl-dr-emm,nl-dr-emc
Erica	Emmen	nl-dr-era	nl,nl-dr,nl-emm,nl-dr-emm,nl-dr-era
Erm	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Eursinge	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-dr-mdd
Exloo	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-stk,nl-dr-boo
Exloërveen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-emm,nl-dr-boo
Fluitenberg	Hoogeveen	nl-dr-dfg	nl,nl-dr,nl-ass,nl-emm,nl-dr-hov,nl-dr-dfg
Foxwolde	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-grq,nl-dr-nov
Frederiksoord	Westerveld	nl-dr-wtv	nl,nl-dr,nl-ov,nl-fr,nl-hrv,nl-dr-wtv
Garminge	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-emm,nl-ass,nl-dr-mdd
Gasselte	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-stk,nl-dr-aah
Gasselternijveen	Aa en Hunze	nl-dr-gss	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah,nl-dr-gss
Gasselternijveenschemond	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah
Gasteren	Aa en Hunze	nl-dr-gst	nl,nl-dr,nl-gr,nl-ass,nl-dr-aah,nl-dr-gst
Geelbroek	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Gees	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Geesbrug	Coevorden	nl-dr-gsb	nl,nl-dr,nl-ov,nl-emm,nl-dr-coe,nl-dr-gsb
Geeuwenbrug	Westerveld	nl-dr-gwu	nl,nl-dr,nl-fr,nl-ass,nl-dr-wtv,nl-dr-gwu
Gieten	Aa en Hunze	nl-dr-gtn	nl,nl-dr,nl-stk,nl-ass,nl-dr-aah,nl-dr-gtn
Gieterveen	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah
Grolloo	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Havelte	Westerveld	nl-dr-hve	nl,nl-dr,nl-ov,nl-hrv,nl-zwo,nl-dr-wtv,nl-dr-hve
Havelterberg	Westerveld	nl-dr-wtv	nl,nl-dr,nl-ov,nl-hrv,nl-dr-wtv
Hijken	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-dr-mdd
Hollandscheveld	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ov,nl-emm,nl-dr-hov
Holsloot	Coevorden	nl-dr-hso	nl,nl-dr,nl-emm,nl-dr-coe,nl-dr-hso
Hoogersmilde	Midden-Drenthe	nl-dr-hmi	nl,nl-dr,nl-fr,nl-ass,nl-dr-mdd,nl-dr-hmi
Hoogersmilde	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ass,nl-dr-wtv
Hoogeveen	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ov,nl-emm,nl-ass,nl-dr-hov,nl-dr-hov
Hooghalen	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-dr-mdd
Huis ter Heide	Noordenveld	nl-dr-hth	nl,nl-dr,nl-fr,nl-ass,nl-dr-nov,nl-dr-hth
Kerkenveld	De Wolden	nl-dr-wod	nl,nl-dr,nl-ov,nl-emm,nl-dr-wod
Klazienaveen	Emmen	nl-dr-klz	nl,nl-dr,nl-emm,nl-dr-emm,nl-dr-klz
Klazienaveen-Noord	Emmen	nl-dr-emm	nl,nl-dr,nl-emm,nl-dr-emm
Klijndijk	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-dr-boo
Koekange	De Wolden	nl-dr-koe	nl,nl-dr,nl-ov,nl-zwo,nl-dr-wod,nl-dr-koe
Langelo	Noordenveld	nl-dr-lgo	nl,nl-dr,nl-gr,nl-fr,nl-ass,nl-dr-nov,nl-dr-lgo
Leutingewolde	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-grq,nl-dr-nov
Lieveren	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-fr,nl-grq,nl-ass,nl-dr-nov
Linde	De Wolden	nl-dr-wod	nl,nl-dr,nl-ov,nl-zwo,nl-dr-wod
Loon	Assen	nl-dr-ass	nl,nl-dr,nl-ass,nl-dr-ass
Mantinge	Midden-Drenthe	nl-dr-mtn	nl,nl-dr,nl-emm,nl-dr-mdd,nl-dr-mtn
Marwijksoord	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Matsloot	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-grq,nl-dr-nov
Meppel	Meppel	nl-dr-mep	nl,nl-dr,nl-ov,nl-zwo,nl-dr-mep,nl-dr-mep
Meppen	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Midlaren	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-grq,nl-ass,nl-dr-tno
Nietap	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-grq,nl-dr-nov
Nieuw Annerveen	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah
Nieuw-Amsterdam	Emmen	nl-dr-nam	nl,nl-dr,nl-emm,nl-dr-emm,nl-dr-nam
Nieuw-Balinge	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-emm,nl-dr-mdd
Nieuw-Buinen	Borger-Odoorn	nl-dr-nb3	nl,nl-dr,nl-gr,nl-stk,nl-dr-boo,nl-dr-nb3
Nieuw-Dordrecht	Emmen	nl-dr-emm	nl,nl-dr,nl-emm,nl-dr-emm
Nieuw-Roden	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-fr,nl-grq,nl-dr-nov
Nieuw-Schoonebeek	Emmen	nl-dr-emm	nl,nl-dr,nl-emm,nl-dr-emm
Nieuw-Weerdinge	Emmen	nl-dr-wee	nl,nl-dr,nl-gr,nl-emm,nl-dr-emm,nl-dr-wee
Nieuwediep	Aa en Hunze	nl-dr-ndi	nl,nl-dr,nl-gr,nl-stk,nl-dr-aah,nl-dr-ndi
Nieuweroord	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ov,nl-emm,nl-dr-hov
Nieuweroord	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ov,nl-emm,nl-dr-mdd
Nieuwlande	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ov,nl-emm,nl-dr-hov
Nieuwlande Coevorden	Coevorden	nl-dr-coe	nl,nl-dr,nl-ov,nl-emm,nl-dr-coe
Nijensleek	Westerveld	nl-dr-wtv	nl,nl-dr,nl-ov,nl-fr,nl-hrv,nl-dr-wtv
Nijeveen	Meppel	nl-dr-jev	nl,nl-dr,nl-ov,nl-zwo,nl-dr-mep,nl-dr-jev
Nijlande	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Nooitgedacht	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Noord-Sleen	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Noordscheschut	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ov,nl-emm,nl-dr-hov
Norg	Noordenveld	nl-dr-nrg	nl,nl-dr,nl-fr,nl-gr,nl-ass,nl-dr-nov,nl-dr-nrg
Odoorn	Borger-Odoorn	nl-dr-odn	nl,nl-dr,nl-emm,nl-dr-boo,nl-dr-odn
Odoornerveen	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-dr-boo
Oosterhesselen	Coevorden	nl-dr-ohn	nl,nl-dr,nl-emm,nl-dr-coe,nl-dr-ohn
Oranje	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-fr,nl-ass,nl-dr-mdd
Orvelte	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-emm,nl-ass,nl-dr-mdd
Oud Annerveen	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-ass,nl-dr-aah
Oude Willem	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ass,nl-dr-wtv
Oudemolen	Tynaarlo	nl-dr-omo	nl,nl-dr,nl-gr,nl-ass,nl-dr-tno,nl-dr-omo
Papenvoort	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Paterswolde	Tynaarlo	nl-dr-pat	nl,nl-dr,nl-gr,nl-grq,nl-dr-tno,nl-dr-pat
Peest	Noordenveld	nl-dr-pet	nl,nl-dr,nl-ass,nl-dr-nov,nl-dr-pet
Peize	Noordenveld	nl-dr-piz	nl,nl-dr,nl-gr,nl-grq,nl-dr-nov,nl-dr-piz
Pesse	Westerveld	nl-dr-pse	nl,nl-dr,nl-ass,nl-dr-wtv,nl-dr-pse
Pesse	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-ass,nl-dr-hov
Rhee	Assen	nl-dr-ass	nl,nl-dr,nl-ass,nl-dr-ass
Roden	Noordenveld	nl-dr-rod	nl,nl-dr,nl-gr,nl-grq,nl-dr-nov,nl-dr-rod
Roderesch	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-fr,nl-grq,nl-ass,nl-dr-nov
Roderwolde	Noordenveld	nl-dr-nov	nl,nl-dr,nl-gr,nl-grq,nl-dr-nov
Rogat	Meppel	nl-dr-rg2	nl,nl-dr,nl-ov,nl-zwo,nl-dr-mep,nl-dr-rg2
Rolde	Aa en Hunze	nl-dr-rol	nl,nl-dr,nl-ass,nl-dr-aah,nl-dr-rol
Roswinkel	Emmen	nl-dr-emm	nl,nl-dr,nl-gr,nl-emm,nl-dr-emm
Ruinen	Westerveld	nl-dr-rui	nl,nl-dr,nl-ass,nl-dr-wtv,nl-dr-rui
Ruinen	De Wolden	nl-dr-wod	nl,nl-dr,nl-ass,nl-dr-wod
Ruinerwold	De Wolden	nl-dr-rwo	nl,nl-dr,nl-ov,nl-zwo,nl-dr-wod,nl-dr-rwo
Schipborg	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-ass,nl-dr-aah
Schoonebeek	Emmen	nl-dr-scb	nl,nl-dr,nl-emm,nl-dr-emm,nl-dr-scb
Schoonloo	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Schoonoord	Coevorden	nl-dr-sc2	nl,nl-dr,nl-emm,nl-dr-coe,nl-dr-sc2
Sleen	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Smilde	Midden-Drenthe	nl-dr-smi	nl,nl-dr,nl-fr,nl-ass,nl-dr-mdd,nl-dr-smi
Spier	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-dr-mdd
Spier	Westerveld	nl-dr-wtv	nl,nl-dr,nl-ass,nl-dr-wtv
Spijkerboor	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-gr,nl-stk,nl-ass,nl-dr-aah
Steenbergen	Noordenveld	nl-dr-ste	nl,nl-dr,nl-gr,nl-fr,nl-ass,nl-dr-nov,nl-dr-ste
Stieltjeskanaal	Coevorden	nl-dr-skl	nl,nl-dr,nl-emm,nl-dr-coe,nl-dr-skl
Stuifzand	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-emm,nl-ass,nl-dr-mdd
Stuifzand	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-emm,nl-ass,nl-dr-hov
Taarlo	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-ass,nl-dr-tno
Ter Aard	Assen	nl-dr-ass	nl,nl-dr,nl-ass,nl-dr-ass
Tiendeveen	Hoogeveen	nl-dr-hov	nl,nl-dr,nl-emm,nl-dr-hov
Tiendeveen	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-emm,nl-dr-mdd
Tynaarlo	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-ass,nl-dr-tno,nl-dr-tno
Ubbena	Assen	nl-dr-ass	nl,nl-dr,nl-gr,nl-ass,nl-dr-ass
Uffelte	Westerveld	nl-dr-ufe	nl,nl-dr,nl-ov,nl-ass,nl-hrv,nl-dr-wtv,nl-dr-ufe
Valthe	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-dr-boo
Valthermond	Borger-Odoorn	nl-dr-vth	nl,nl-dr,nl-gr,nl-stk,nl-emm,nl-dr-boo,nl-dr-vth
Veenhuizen	Noordenveld	nl-dr-nov	nl,nl-dr,nl-fr,nl-ass,nl-dr-nov
Veeningen	De Wolden	nl-dr-wod	nl,nl-dr,nl-ov,nl-zwo,nl-dr-wod
Veenoord	Emmen	nl-dr-vno	nl,nl-dr,nl-emm,nl-dr-emm,nl-dr-vno
Vledder	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ov,nl-hrv,nl-dr-wtv
Vledderveen	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ov,nl-hrv,nl-dr-wtv
Vredenheim	Aa en Hunze	nl-dr-aah	nl,nl-dr,nl-ass,nl-dr-aah
Vries	Tynaarlo	nl-dr-vis	nl,nl-dr,nl-gr,nl-ass,nl-dr-tno,nl-dr-vis
Wachtum	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Wapse	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ov,nl-ass,nl-hrv,nl-dr-wtv
Wapserveen	Westerveld	nl-dr-wtv	nl,nl-dr,nl-ov,nl-fr,nl-hrv,nl-dr-wtv
Wateren	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ass,nl-dr-wtv
Weiteveen	Emmen	nl-dr-emm	nl,nl-dr,nl-emm,nl-dr-emm
Westdorp	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-emm,nl-stk,nl-dr-boo
Westerbork	Midden-Drenthe	nl-dr-wbk	nl,nl-dr,nl-ass,nl-dr-mdd,nl-dr-wbk
Westervelde	Noordenveld	nl-dr-nov	nl,nl-dr,nl-fr,nl-gr,nl-ass,nl-dr-nov
Wezup	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Wezuperbrug	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Wijster	Midden-Drenthe	nl-dr-wjs	nl,nl-dr,nl-ass,nl-dr-mdd,nl-dr-wjs
Wilhelminaoord	Westerveld	nl-dr-wha	nl,nl-dr,nl-fr,nl-ov,nl-hrv,nl-dr-wtv,nl-dr-wha
Winde	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-grq,nl-dr-tno
Wittelte	Westerveld	nl-dr-wit	nl,nl-dr,nl-ov,nl-ass,nl-dr-wtv,nl-dr-wit
Witteveen	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-emm,nl-dr-mdd
Yde	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-grq,nl-ass,nl-dr-tno
Zandberg	Borger-Odoorn	nl-dr-boo	nl,nl-dr,nl-gr,nl-stk,nl-dr-boo
Zandpol	Emmen	nl-dr-zpo	nl,nl-dr,nl-emm,nl-dr-emm,nl-dr-zpo
Zeegse	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-ass,nl-dr-tno
Zeijen	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-ass,nl-dr-tno
Zeijerveen	Assen	nl-dr-ass	nl,nl-dr,nl-ass,nl-dr-ass
Zeijerveld	Assen	nl-dr-ass	nl,nl-dr,nl-ass,nl-dr-ass
Zorgvlied	Westerveld	nl-dr-wtv	nl,nl-dr,nl-fr,nl-ass,nl-hrv,nl-dr-wtv
Zuidlaarderveen	Tynaarlo	nl-dr-tno	nl,nl-dr,nl-gr,nl-ass,nl-grq,nl-stk,nl-dr-tno
Zuidlaren	Tynaarlo	nl-dr-zdl	nl,nl-dr,nl-gr,nl-ass,nl-dr-tno,nl-dr-zdl
Zuidveld	Midden-Drenthe	nl-dr-mdd	nl,nl-dr,nl-ass,nl-dr-mdd
Zuidvelde	Noordenveld	nl-dr-nov	nl,nl-dr,nl-fr,nl-ass,nl-dr-nov
Zuidwolde	De Wolden	nl-dr-zwl	nl,nl-dr,nl-ov,nl-zwo,nl-dr-wod,nl-dr-zwl
Zwartemeer	Emmen	nl-dr-emm	nl,nl-dr,nl-emm,nl-dr-emm
Zweeloo	Coevorden	nl-dr-coe	nl,nl-dr,nl-emm,nl-dr-coe
Zwiggelte	Midden-Drenthe	nl-dr-zge	nl,nl-dr,nl-ass,nl-dr-mdd,nl-dr-zge
Zwinderen	Coevorden	nl-dr-zwn	nl,nl-dr,nl-ov,nl-emm,nl-dr-coe,nl-dr-zwn
's-Heerenbroek	Kampen	nl-ov-shb	nl,nl-ov,nl-ge,nl-zwo,nl-ov-kam,nl-ov-shb
Aadorp	Almelo	nl-ov-alm	nl,nl-ov,nl-alm,nl-ov-alm
Agelo	Dinkelland	nl-ov-ikl	nl,nl-ov,nl-hgl,nl-alm,nl-ov-ikl
Albergen	Tubbergen	nl-ov-abn	nl,nl-ov,nl-alm,nl-hgl,nl-ov-tbb,nl-ov-abn
Almelo	Almelo	nl-ov-alm	nl,nl-ov,nl-alm,nl-ov-alm,nl-ov-alm
Ambt Delden	Hof van Twente	nl-ov-htw	nl,nl-ov,nl-hgl,nl-alm,nl-ov-htw
Ane	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-emm,nl-ov-hbg
Anerveen	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-emm,nl-ov-hbg
Anevelde	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-emm,nl-alm,nl-ov-hbg
Arriën	Ommen	nl-ov-omm	nl,nl-ov,nl-alm,nl-zwo,nl-ov-omm
Baarlo	Steenwijkerland	nl-ov-blo	nl,nl-ov,nl-fl,nl-fr,nl-hrv,nl-ov-sew,nl-ov-blo
Baars	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-dr,nl-hrv,nl-ov-sew
Balkbrug	Hardenberg	nl-ov-bkb	nl,nl-ov,nl-dr,nl-zwo,nl-ov-hbg,nl-ov-bkb
Basse	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-dr,nl-hrv,nl-ov-sew
Bathmen	Deventer	nl-ov-bth	nl,nl-ov,nl-ge,nl-dev,nl-ov-dev,nl-ov-bth
Beerze	Ommen	nl-ov-omm	nl,nl-ov,nl-alm,nl-ov-omm
Beerzerveld	Ommen	nl-ov-omm	nl,nl-ov,nl-alm,nl-ov-omm
Belt-Schutsloot	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-dr,nl-zwo,nl-ov-sew
Bentelo	Hof van Twente	nl-ov-bto	nl,nl-ov,nl-ge,nl-hgl,nl-ov-htw,nl-ov-bto
Bergentheim	Hardenberg	nl-ov-bgh	nl,nl-ov,nl-alm,nl-ov-hbg,nl-ov-bgh
Beuningen	Losser	nl-ov-bnn	nl,nl-ov,nl-hgl,nl-ov-los,nl-ov-bnn
Blankenham	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fl,nl-fr,nl-hrv,nl-ov-sew
Blokzijl	Steenwijkerland	nl-ov-bzl	nl,nl-ov,nl-fl,nl-zwo,nl-hrv,nl-ov-sew,nl-ov-bzl
Borne	Borne	nl-ov-bre	nl,nl-ov,nl-hgl,nl-alm,nl-ov-bre,nl-ov-bre
Bornerbroek	Almelo	nl-ov-bnb	nl,nl-ov,nl-alm,nl-hgl,nl-ov-alm,nl-ov-bnb
Broekland	Raalte	nl-ov-qds	nl,nl-ov,nl-ge,nl-dev,nl-ov-qds
Brucht	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Bruchterveld	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Bruinehaar	Twenterand	nl-ov-twt	nl,nl-ov,nl-alm,nl-ov-twt
Collendoorn	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-alm,nl-emm,nl-ov-hbg
Colmschate	Deventer	nl-ov-chj	nl,nl-ov,nl-ge,nl-dev,nl-ov-dev,nl-ov-chj
Daarle	Hellendoorn	nl-ov-hld	nl,nl-ov,nl-alm,nl-ov-hld
Daarlerveen	Hellendoorn	nl-ov-hld	nl,nl-ov,nl-alm,nl-ov-hld
Dalfsen	Dalfsen	nl-ov-dal	nl,nl-ov,nl-zwo,nl-ov-dal,nl-ov-dal
Dalmsholte	Ommen	nl-ov-omm	nl,nl-ov,nl-zwo,nl-ov-omm
De Bult	Steenwijkerland	nl-ov-dbt	nl,nl-ov,nl-dr,nl-fr,nl-hrv,nl-ov-sew,nl-ov-dbt
De Krim	Hardenberg	nl-ov-dkr	nl,nl-ov,nl-dr,nl-emm,nl-ov-hbg,nl-ov-dkr
de Lutte	Losser	nl-ov-dlu	nl,nl-ov,nl-hgl,nl-ov-los,nl-ov-dlu
De Pol	Steenwijkerland	nl-ov-dpo	nl,nl-ov,nl-fr,nl-dr,nl-hrv,nl-ov-sew,nl-ov-dpo
Dedemsvaart	Hardenberg	nl-ov-ded	nl,nl-ov,nl-dr,nl-zwo,nl-ov-hbg,nl-ov-ded
Delden	Hof van Twente	nl-ov-del	nl,nl-ov,nl-hgl,nl-alm,nl-ov-htw,nl-ov-del
Den Ham	Twenterand	nl-ov-dh2	nl,nl-ov,nl-alm,nl-ov-twt,nl-ov-dh2
Den Velde	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-emm,nl-alm,nl-ov-hbg
Denekamp	Dinkelland	nl-ov-den	nl,nl-ov,nl-hgl,nl-ov-ikl,nl-ov-den
Deurningen	Oldenzaal	nl-ov-azq	nl,nl-ov,nl-hgl,nl-alm,nl-ov-olz,nl-ov-azq
Deurningen	Dinkelland	nl-ov-ikl	nl,nl-ov,nl-hgl,nl-alm,nl-ov-ikl
Deventer	Deventer	nl-ov-dev	nl,nl-ov,nl-ge,nl-dev,nl-ov-dev,nl-ov-dev
Diepenheim	Hof van Twente	nl-ov-dph	nl,nl-ov,nl-ge,nl-hgl,nl-alm,nl-ov-htw,nl-ov-dph
Diepenveen	Deventer	nl-ov-dev	nl,nl-ov,nl-ge,nl-dev,nl-ov-dev
Diffelen	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Eesveen	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-dr,nl-fr,nl-hrv,nl-ov-sew
Enschede	Enschede	nl-ov-ens	nl,nl-ov,nl-hgl,nl-ov-ens,nl-ov-ens
Enter	Wierden	nl-ov-ent	nl,nl-ov,nl-alm,nl-ov-wid,nl-ov-ent
Fleringen	Tubbergen	nl-ov-fle	nl,nl-ov,nl-alm,nl-hgl,nl-ov-tbb,nl-ov-fle
Geerdijk	Twenterand	nl-ov-twt	nl,nl-ov,nl-alm,nl-ov-twt
Geesteren	Tubbergen	nl-ov-ges	nl,nl-ov,nl-alm,nl-ov-tbb,nl-ov-ges
Genemuiden	Zwartewaterland	nl-ov-gnm	nl,nl-ov,nl-zwo,nl-ov-gnm,nl-ov-gnm
Giethmen	Ommen	nl-ov-omm	nl,nl-ov,nl-zwo,nl-alm,nl-ov-omm
Giethoorn	Steenwijkerland	nl-ov-gho	nl,nl-ov,nl-dr,nl-zwo,nl-hrv,nl-ov-sew,nl-ov-gho
Glane	Losser	nl-ov-los	nl,nl-ov,nl-hgl,nl-ov-los
Goor	Hof van Twente	nl-ov-goo	nl,nl-ov,nl-ge,nl-hgl,nl-alm,nl-ov-htw,nl-ov-goo
Grafhorst	Kampen	nl-ov-kam	nl,nl-ov,nl-ge,nl-fl,nl-zwo,nl-ov-kam
Gramsbergen	Hardenberg	nl-ov-gbg	nl,nl-ov,nl-dr,nl-emm,nl-ov-hbg,nl-ov-gbg
Haaksbergen	Haaksbergen	nl-ov-hkh	nl,nl-ov,nl-ge,nl-hgl,nl-ov-hkh,nl-ov-hkh
Haarle	Hellendoorn	nl-ov-hld	nl,nl-ov,nl-dev,nl-alm,nl-ov-hld
Harbrinkhoek	Tubbergen	nl-ov-hbh	nl,nl-ov,nl-alm,nl-ov-tbb,nl-ov-hbh
Hardenberg	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-alm,nl-ov-hbg,nl-ov-hbg
Hasselt	Zwartewaterland	nl-ov-has	nl,nl-ov,nl-zwo,nl-ov-gnm,nl-ov-has
Heemserveen	Hardenberg	nl-ov-hmv	nl,nl-ov,nl-dr,nl-alm,nl-ov-hbg,nl-ov-hmv
Heeten	Raalte	nl-ov-het	nl,nl-ov,nl-dev,nl-ov-qds,nl-ov-het
Heino	Raalte	nl-ov-hno	nl,nl-ov,nl-ge,nl-zwo,nl-ov-qds,nl-ov-hno
Hellendoorn	Hellendoorn	nl-ov-hld	nl,nl-ov,nl-alm,nl-ov-hld,nl-ov-hld
Hengelo	Hengelo (O)	nl-ov-hgl	nl,nl-ov,nl-hgl,nl-ov-hgl,nl-ov-hgl
Hengevelde	Hof van Twente	nl-ov-hev	nl,nl-ov,nl-ge,nl-hgl,nl-ov-htw,nl-ov-hev
Hertme	Borne	nl-ov-hrt	nl,nl-ov,nl-hgl,nl-alm,nl-ov-bre,nl-ov-hrt
Hezingen	Tubbergen	nl-ov-tbb	nl,nl-ov,nl-alm,nl-ov-tbb
Hoge Hexel	Wierden	nl-ov-wid	nl,nl-ov,nl-alm,nl-ov-wid
Holten	Rijssen-Holten	nl-ov-hlt	nl,nl-ov,nl-dev,nl-alm,nl-ov-rih,nl-ov-hlt
Holtheme	Hardenberg	nl-ov-hme	nl,nl-ov,nl-dr,nl-emm,nl-ov-hbg,nl-ov-hme
Holthone	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-emm,nl-ov-hbg
Hoogenweg	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
IJhorst	Staphorst	nl-ov-ijh	nl,nl-ov,nl-dr,nl-zwo,nl-ov-sth,nl-ov-ijh
IJsselham	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-fl,nl-hrv,nl-ov-sew
IJsselmuiden	Kampen	nl-ov-ism	nl,nl-ov,nl-ge,nl-zwo,nl-ov-kam,nl-ov-ism
Kalenberg	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-fl,nl-hrv,nl-ov-sew
Kallenkote	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-dr,nl-fr,nl-hrv,nl-ov-sew
Kampen	Kampen	nl-ov-kam	nl,nl-ov,nl-ge,nl-zwo,nl-ov-kam,nl-ov-kam
Kamperveen	Kampen	nl-ov-kam	nl,nl-ov,nl-ge,nl-zwo,nl-ov-kam
Kloosterhaar	Twenterand	nl-ov-twt	nl,nl-ov,nl-alm,nl-ov-twt
Kloosterhaar	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Kuinre	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-fl,nl-hrv,nl-ov-sew
Laag Zuthem	Raalte	nl-ov-qds	nl,nl-ov,nl-ge,nl-zwo,nl-ov-qds
Langeveen	Tubbergen	nl-ov-tbb	nl,nl-ov,nl-alm,nl-ov-tbb
Lattrop-Breklenkamp	Dinkelland	nl-ov-ikl	nl,nl-ov,nl-hgl,nl-alm,nl-ov-ikl
Lemele	Ommen	nl-ov-omm	nl,nl-ov,nl-alm,nl-ov-omm
Lemelerveld	Dalfsen	nl-ov-ele	nl,nl-ov,nl-zwo,nl-ov-dal,nl-ov-ele
Lettele	Deventer	nl-ov-tte	nl,nl-ov,nl-ge,nl-dev,nl-ov-dev,nl-ov-tte
Lierderholthuis	Raalte	nl-ov-qds	nl,nl-ov,nl-ge,nl-zwo,nl-ov-qds
Loozen	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-alm,nl-emm,nl-ov-hbg
Losser	Losser	nl-ov-los	nl,nl-ov,nl-hgl,nl-ov-los,nl-ov-los
Lutten	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-alm,nl-emm,nl-ov-hbg
Luttenberg	Raalte	nl-ov-ltt	nl,nl-ov,nl-alm,nl-zwo,nl-dev,nl-ov-qds,nl-ov-ltt
Mander	Tubbergen	nl-ov-tbb	nl,nl-ov,nl-alm,nl-ov-tbb
Manderveen	Tubbergen	nl-ov-tbb	nl,nl-ov,nl-alm,nl-ov-tbb
Mariaparochie	Tubbergen	nl-ov-tbb	nl,nl-ov,nl-alm,nl-hgl,nl-ov-tbb
Marijenkampen	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-dr,nl-hrv,nl-ov-sew
Mariënberg	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Mariënheem	Raalte	nl-ov-qds	nl,nl-ov,nl-dev,nl-ov-qds
Markelo	Hof van Twente	nl-ov-mar	nl,nl-ov,nl-ge,nl-alm,nl-ov-htw,nl-ov-mar
Marle	Olst-Wijhe	nl-ov-obk	nl,nl-ov,nl-ge,nl-zwo,nl-ov-obk
Mastenbroek	Zwartewaterland	nl-ov-gnm	nl,nl-ov,nl-zwo,nl-ov-gnm
Mastenbroek	Kampen	nl-ov-kam	nl,nl-ov,nl-zwo,nl-ov-kam
Nederland	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fl,nl-fr,nl-hrv,nl-ov-sew
Nieuw Heeten	Raalte	nl-ov-qds	nl,nl-ov,nl-dev,nl-ov-qds
Nieuwleusen	Dalfsen	nl-ov-nwl	nl,nl-ov,nl-dr,nl-zwo,nl-ov-dal,nl-ov-nwl
Nijverdal	Hellendoorn	nl-ov-nvd	nl,nl-ov,nl-alm,nl-ov-hld,nl-ov-nvd
Notter	Wierden	nl-ov-wid	nl,nl-ov,nl-alm,nl-ov-wid
Nutter	Dinkelland	nl-ov-ikl	nl,nl-ov,nl-alm,nl-ov-ikl
Okkenbroek	Deventer	nl-ov-dev	nl,nl-ov,nl-ge,nl-dev,nl-ov-dev
Oldemarkt	Steenwijkerland	nl-ov-olk	nl,nl-ov,nl-fr,nl-hrv,nl-ov-sew,nl-ov-olk
Oldenzaal	Oldenzaal	nl-ov-olz	nl,nl-ov,nl-hgl,nl-ov-olz,nl-ov-olz
Olst	Olst-Wijhe	nl-ov-osi	nl,nl-ov,nl-ge,nl-dev,nl-ov-obk,nl-ov-osi
Ommen	Ommen	nl-ov-omm	nl,nl-ov,nl-zwo,nl-alm,nl-ov-omm,nl-ov-omm
Onna	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-dr,nl-hrv,nl-ov-sew
Ootmarsum	Dinkelland	nl-ov-oot	nl,nl-ov,nl-alm,nl-hgl,nl-ov-ikl,nl-ov-oot
Ossenzijl	Steenwijkerland	nl-ov-ozl	nl,nl-ov,nl-fr,nl-fl,nl-hrv,nl-ov-sew,nl-ov-ozl
Oud Ootmarsum	Dinkelland	nl-ov-ikl	nl,nl-ov,nl-alm,nl-hgl,nl-ov-ikl
Overdinkel	Losser	nl-ov-oov	nl,nl-ov,nl-hgl,nl-ov-los,nl-ov-oov
Paasloo	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-hrv,nl-ov-sew
Punthorst	Staphorst	nl-ov-sth	nl,nl-ov,nl-dr,nl-zwo,nl-ov-sth
Raalte	Raalte	nl-ov-qds	nl,nl-ov,nl-dev,nl-zwo,nl-ov-qds,nl-ov-qds
Radewijk	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Reeve	Kampen	nl-ov-kam	nl,nl-ov,nl-ge,nl-zwo,nl-ov-kam
Reutum	Tubbergen	nl-ov-tbb	nl,nl-ov,nl-alm,nl-ov-tbb
Rheeze	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-alm,nl-ov-hbg
Rheezerveen	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-alm,nl-ov-hbg
Rijssen	Rijssen-Holten	nl-ov-rjs	nl,nl-ov,nl-alm,nl-ov-rih,nl-ov-rjs
Rossum	Dinkelland	nl-ov-grm	nl,nl-ov,nl-hgl,nl-ov-ikl,nl-ov-grm
Rouveen	Staphorst	nl-ov-ree	nl,nl-ov,nl-dr,nl-zwo,nl-ov-sth,nl-ov-ree
Saasveld	Dinkelland	nl-ov-sve	nl,nl-ov,nl-hgl,nl-alm,nl-ov-ikl,nl-ov-sve
Schalkhaar	Deventer	nl-ov-dev	nl,nl-ov,nl-ge,nl-dev,nl-ov-dev
Scheerwolde	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-hrv,nl-ov-sew
Schuinesloot	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-dr,nl-emm,nl-ov-hbg
Sibculo	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Sint Jansklooster	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fl,nl-zwo,nl-ov-sew
Slagharen	Hardenberg	nl-ov-lgr	nl,nl-ov,nl-dr,nl-emm,nl-alm,nl-ov-hbg,nl-ov-lgr
Staphorst	Staphorst	nl-ov-sth	nl,nl-ov,nl-dr,nl-zwo,nl-ov-sth,nl-ov-sth
Steenwijk	Steenwijkerland	nl-ov-stw	nl,nl-ov,nl-dr,nl-fr,nl-hrv,nl-ov-sew,nl-ov-stw
Steenwijkerwold	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-dr,nl-hrv,nl-ov-sew
Stegeren	Ommen	nl-ov-omm	nl,nl-ov,nl-alm,nl-ov-omm
Tilligte	Dinkelland	nl-ov-ikl	nl,nl-ov,nl-hgl,nl-alm,nl-ov-ikl
Tubbergen	Tubbergen	nl-ov-tbb	nl,nl-ov,nl-alm,nl-ov-tbb,nl-ov-tbb
Tuk	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-dr,nl-fr,nl-hrv,nl-ov-sew
Vasse	Tubbergen	nl-ov-vss	nl,nl-ov,nl-alm,nl-ov-tbb,nl-ov-vss
Venebrugge	Hardenberg	nl-ov-hbg	nl,nl-ov,nl-alm,nl-ov-hbg
Vilsteren	Ommen	nl-ov-vtr	nl,nl-ov,nl-zwo,nl-ov-omm,nl-ov-vtr
Vinkenbuurt	Ommen	nl-ov-vkb	nl,nl-ov,nl-dr,nl-zwo,nl-ov-omm,nl-ov-vkb
Vollenhove	Steenwijkerland	nl-ov-vhv	nl,nl-ov,nl-fl,nl-zwo,nl-ov-sew,nl-ov-vhv
Vriezenveen	Twenterand	nl-ov-vrz	nl,nl-ov,nl-alm,nl-ov-twt,nl-ov-vrz
Vroomshoop	Twenterand	nl-ov-vrh	nl,nl-ov,nl-alm,nl-ov-twt,nl-ov-vrh
Wanneperveen	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-dr,nl-zwo,nl-ov-sew
Weerselo	Dinkelland	nl-ov-wro	nl,nl-ov,nl-hgl,nl-alm,nl-ov-ikl,nl-ov-wro
Welsum	Olst-Wijhe	nl-ov-obk	nl,nl-ov,nl-ge,nl-dev,nl-ov-obk
Wesepe	Olst-Wijhe	nl-ov-wpp	nl,nl-ov,nl-ge,nl-dev,nl-ov-obk,nl-ov-wpp
Westerhaar-Vriezenveensewijk	Twenterand	nl-ov-wes	nl,nl-ov,nl-alm,nl-ov-twt,nl-ov-wes
Wetering	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-fl,nl-hrv,nl-ov-sew
Wierden	Wierden	nl-ov-wid	nl,nl-ov,nl-alm,nl-ov-wid,nl-ov-wid
Wijhe	Olst-Wijhe	nl-ov-wij	nl,nl-ov,nl-ge,nl-zwo,nl-dev,nl-ov-obk,nl-ov-wij
Willemsoord	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-dr,nl-hrv,nl-ov-sew
Wilsum	Kampen	nl-ov-kam	nl,nl-ov,nl-ge,nl-zwo,nl-ov-kam
Witharen	Ommen	nl-ov-wth	nl,nl-ov,nl-dr,nl-zwo,nl-ov-omm,nl-ov-wth
Witte Paarden	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-fr,nl-dr,nl-hrv,nl-ov-sew
Zalk	Kampen	nl-ov-zlk	nl,nl-ov,nl-ge,nl-zwo,nl-ov-kam,nl-ov-zlk
Zenderen	Borne	nl-ov-znd	nl,nl-ov,nl-alm,nl-hgl,nl-ov-bre,nl-ov-znd
Zuidveen	Steenwijkerland	nl-ov-sew	nl,nl-ov,nl-dr,nl-fr,nl-hrv,nl-ov-sew
Zuna	Wierden	nl-ov-zun	nl,nl-ov,nl-alm,nl-ov-wid,nl-ov-zun
Zwartsluis	Zwartewaterland	nl-ov-zws	nl,nl-ov,nl-dr,nl-zwo,nl-ov-gnm,nl-ov-zws
Zwolle	Zwolle	nl-ov-zwo	nl,nl-ov,nl-ge,nl-zwo,nl-ov-zwo,nl-ov-zwo
Almere	Almere	nl-fl-aer	nl,nl-fl,nl-nh,nl-aer,nl-fl-aer,nl-fl-aer
Bant	Noordoostpolder	nl-fl-ban	nl,nl-fl,nl-ov,nl-fr,nl-hrv,nl-fl-nop,nl-fl-ban
Biddinghuizen	Dronten	nl-fl-bnz	nl,nl-fl,nl-ge,nl-ley,nl-fl-dro,nl-fl-bnz
Creil	Noordoostpolder	nl-fl-cri	nl,nl-fl,nl-fr,nl-hrv,nl-ley,nl-fl-nop,nl-fl-cri
Dronten	Dronten	nl-fl-dro	nl,nl-fl,nl-ley,nl-fl-dro,nl-fl-dro
Emmeloord	Noordoostpolder	nl-fl-eml	nl,nl-fl,nl-ley,nl-hrv,nl-fl-nop,nl-fl-eml
Ens	Noordoostpolder	nl-fl-enx	nl,nl-fl,nl-ov,nl-zwo,nl-fl-nop,nl-fl-enx
Espel	Noordoostpolder	nl-fl-esp	nl,nl-fl,nl-ley,nl-fl-nop,nl-fl-esp
Kraggenburg	Noordoostpolder	nl-fl-kgb	nl,nl-fl,nl-ov,nl-zwo,nl-fl-nop,nl-fl-kgb
Lelystad	Lelystad	nl-fl-ley	nl,nl-fl,nl-ley,nl-fl-ley,nl-fl-ley
Luttelgeest	Noordoostpolder	nl-fl-lge	nl,nl-fl,nl-ov,nl-fr,nl-hrv,nl-fl-nop,nl-fl-lge
Marknesse	Noordoostpolder	nl-fl-man	nl,nl-fl,nl-ov,nl-zwo,nl-hrv,nl-fl-nop,nl-fl-man
Nagele	Noordoostpolder	nl-fl-nlg	nl,nl-fl,nl-ley,nl-fl-nop,nl-fl-nlg
Rutten	Noordoostpolder	nl-fl-rut	nl,nl-fl,nl-fr,nl-ov,nl-hrv,nl-fl-nop,nl-fl-rut
Schokland	Noordoostpolder	nl-fl-nop	nl,nl-fl,nl-ley,nl-zwo,nl-fl-nop
Swifterbant	Dronten	nl-fl-swi	nl,nl-fl,nl-ley,nl-fl-dro,nl-fl-swi
Tollebeek	Noordoostpolder	nl-fl-tok	nl,nl-fl,nl-ley,nl-fl-nop,nl-fl-tok
Urk	Urk	nl-fl-urk	nl,nl-fl,nl-ley,nl-fl-urk,nl-fl-urk
Zeewolde	Zeewolde	nl-fl-zew	nl,nl-fl,nl-ge,nl-ley,nl-ame,nl-aer,nl-fl-zew,nl-fl-zew
's-Heerenberg	Montferland	nl-ge-hrb	nl,nl-ge,nl-doi,nl-ge-mtl,nl-ge-hrb
't Harde	Elburg	nl-ge-tha	nl,nl-ge,nl-zwo,nl-ge-elb,nl-ge-tha
't Loo Oldebroek	Oldebroek	nl-ge-olb	nl,nl-ge,nl-ov,nl-zwo,nl-ge-olb
Aalst	Zaltbommel	nl-ge-aal	nl,nl-ge,nl-nb,nl-zh,nl-htb,nl-ge-zlb,nl-ge-aal
Aalten	Aalten	nl-ge-lte	nl,nl-ge,nl-doi,nl-ge-lte,nl-ge-lte
Achterveld	Barneveld	nl-ge-ach	nl,nl-ge,nl-ut,nl-ame,nl-ge-bar,nl-ge-ach
Acquoy	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-ut,nl-zh,nl-utc,nl-htb,nl-ge-gdm
Aerdt	Zevenaar	nl-ge-zev	nl,nl-ge,nl-arn,nl-nij,nl-doi,nl-ge-zev
Afferden	Druten	nl-ge-dru	nl,nl-ge,nl-nb,nl-ut,nl-oss,nl-ge-dru
Alem	Maasdriel	nl-ge-mdr	nl,nl-ge,nl-nb,nl-htb,nl-oss,nl-ge-mdr
Almen	Lochem	nl-ge-amn	nl,nl-ge,nl-dev,nl-ge-lch,nl-ge-amn
Alphen	West Maas en Waal	nl-ge-aph	nl,nl-ge,nl-nb,nl-oss,nl-ge-wmw,nl-ge-aph
Altforst	West Maas en Waal	nl-ge-art	nl,nl-ge,nl-nb,nl-oss,nl-ge-wmw,nl-ge-art
Ammerzoden	Maasdriel	nl-ge-amz	nl,nl-ge,nl-nb,nl-htb,nl-ge-mdr,nl-ge-amz
Andelst	Overbetuwe	nl-ge-ant	nl,nl-ge,nl-nij,nl-ge-qcu,nl-ge-ant
Angeren	Lingewaard	nl-ge-ren	nl,nl-ge,nl-arn,nl-nij,nl-ge-lir,nl-ge-ren
Angerlo	Zevenaar	nl-ge-ang	nl,nl-ge,nl-doi,nl-ge-zev,nl-ge-ang
Apeldoorn	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ape,nl-ge-ape,nl-ge-ape
Appeltern	West Maas en Waal	nl-ge-apl	nl,nl-ge,nl-nb,nl-oss,nl-ge-wmw,nl-ge-apl
Arnhem	Arnhem	nl-ge-arn	nl,nl-ge,nl-arn,nl-ge-arn,nl-ge-arn
Asch	Buren	nl-ge-asc	nl,nl-ge,nl-ut,nl-utc,nl-oss,nl-ge-bur,nl-ge-asc
Asperen	West Betuwe	nl-ge-asp	nl,nl-ge,nl-ut,nl-zh,nl-utc,nl-htb,nl-ge-gdm,nl-ge-asp
Azewijn	Montferland	nl-ge-azg	nl,nl-ge,nl-doi,nl-ge-mtl,nl-ge-azg
Baak	Bronckhorst	nl-ge-ba2	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-ba2
Babberich	Zevenaar	nl-ge-bbr	nl,nl-ge,nl-doi,nl-ge-zev,nl-ge-bbr
Balgoij	Wijchen	nl-ge-wch	nl,nl-ge,nl-nb,nl-nij,nl-oss,nl-ge-wch
Barchem	Lochem	nl-ge-lch	nl,nl-ge,nl-doi,nl-ge-lch
Barneveld	Barneveld	nl-ge-bar	nl,nl-ge,nl-ut,nl-ede,nl-ame,nl-ge-bar,nl-ge-bar
Batenburg	Wijchen	nl-ge-wch	nl,nl-ge,nl-nb,nl-oss,nl-ge-wch
Beek	Berg en Dal	nl-ge-beq	nl,nl-ge,nl-li,nl-nb,nl-nij,nl-ge-zat,nl-ge-beq
Beekbergen	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ape,nl-ge-ape
Beemte Broekland	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ov,nl-ape,nl-dev,nl-ge-ape
Beesd	West Betuwe	nl-ge-bsd	nl,nl-ge,nl-ut,nl-htb,nl-utc,nl-ge-gdm,nl-ge-bsd
Beltrum	Berkelland	nl-ge-kll	nl,nl-ge,nl-doi,nl-ge-kll
Bemmel	Lingewaard	nl-ge-bem	nl,nl-ge,nl-nij,nl-arn,nl-ge-lir,nl-ge-bem
Beneden-Leeuwen	West Maas en Waal	nl-ge-buw	nl,nl-ge,nl-nb,nl-ut,nl-oss,nl-ge-wmw,nl-ge-buw
Bennekom	Ede	nl-ge-bkm	nl,nl-ge,nl-ut,nl-ede,nl-ge-ede,nl-ge-bkm
Berg en Dal	Berg en Dal	nl-ge-zat	nl,nl-ge,nl-li,nl-nb,nl-nij,nl-ge-zat
Bergharen	Wijchen	nl-ge-bhr	nl,nl-ge,nl-nb,nl-oss,nl-nij,nl-ge-wch,nl-ge-bhr
Bern	Zaltbommel	nl-ge-zlb	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb
Beuningen Gld	Beuningen	nl-ge-bnn	nl,nl-ge,nl-nij,nl-ge-bnn
Beusichem	Buren	nl-ge-bec	nl,nl-ge,nl-ut,nl-utc,nl-ge-bur,nl-ge-bec
Borculo	Berkelland	nl-ge-brc	nl,nl-ge,nl-ov,nl-doi,nl-ge-kll,nl-ge-brc
Boven-Leeuwen	West Maas en Waal	nl-ge-bvl	nl,nl-ge,nl-nb,nl-ut,nl-oss,nl-ge-wmw,nl-ge-bvl
Braamt	Montferland	nl-ge-bmt	nl,nl-ge,nl-doi,nl-ge-mtl,nl-ge-bmt
Brakel	Zaltbommel	nl-ge-brk	nl,nl-ge,nl-nb,nl-ut,nl-htb,nl-ge-zlb,nl-ge-brk
Bredevoort	Aalten	nl-ge-bdv	nl,nl-ge,nl-doi,nl-ge-lte,nl-ge-bdv
Breedenbroek	Oude IJsselstreek	nl-ge-oat	nl,nl-ge,nl-doi,nl-ge-oat
Bronkhorst	Bronckhorst	nl-ge-bck	nl,nl-ge,nl-doi,nl-ge-bck
Bruchem	Zaltbommel	nl-ge-bru	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb,nl-ge-bru
Brummen	Brummen	nl-ge-brm	nl,nl-ge,nl-doi,nl-ge-brm,nl-ge-brm
Buren	Buren	nl-ge-bur	nl,nl-ge,nl-ut,nl-oss,nl-ge-bur,nl-ge-bur
Buurmalsen	Buren	nl-ge-bur	nl,nl-ge,nl-ut,nl-oss,nl-htb,nl-ge-bur
Buurmalsen	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-ut,nl-oss,nl-htb,nl-ge-gdm
Culemborg	Culemborg	nl-ge-cub	nl,nl-ge,nl-ut,nl-utc,nl-ge-cub,nl-ge-cub
De Glind	Barneveld	nl-ge-zam	nl,nl-ge,nl-ut,nl-ame,nl-ede,nl-ge-bar,nl-ge-zam
De Heurne	Aalten	nl-ge-eug	nl,nl-ge,nl-doi,nl-ge-lte,nl-ge-eug
De Klomp	Ede	nl-ge-dkl	nl,nl-ge,nl-ut,nl-ede,nl-ge-ede,nl-ge-dkl
De Steeg	Rheden	nl-ge-dsg	nl,nl-ge,nl-arn,nl-ge-rhd,nl-ge-dsg
Deelen	Ede	nl-ge-ede	nl,nl-ge,nl-arn,nl-ge-ede
Deest	Druten	nl-ge-dst	nl,nl-ge,nl-nb,nl-ut,nl-nij,nl-ge-dru,nl-ge-dst
Deil	West Betuwe	nl-ge-dll	nl,nl-ge,nl-ut,nl-htb,nl-oss,nl-utc,nl-ge-gdm,nl-ge-dll
Delwijnen	Zaltbommel	nl-ge-zlb	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb
Didam	Montferland	nl-ge-ddm	nl,nl-ge,nl-doi,nl-ge-mtl,nl-ge-ddm
Dieren	Rheden	nl-ge-dir	nl,nl-ge,nl-arn,nl-doi,nl-ge-rhd,nl-ge-dir
Dinxperlo	Aalten	nl-ge-dxp	nl,nl-ge,nl-doi,nl-ge-lte,nl-ge-dxp
Dodewaard	Neder-Betuwe	nl-ge-dwa	nl,nl-ge,nl-ut,nl-ede,nl-nij,nl-ge-nbw,nl-ge-dwa
Doesburg	Doesburg	nl-ge-doe	nl,nl-ge,nl-doi,nl-ge-doe,nl-ge-doe
Doetinchem	Doetinchem	nl-ge-doi	nl,nl-ge,nl-doi,nl-ge-doi,nl-ge-doi
Doornenburg	Lingewaard	nl-ge-cgh	nl,nl-ge,nl-nij,nl-arn,nl-ge-lir,nl-ge-cgh
Doornspijk	Elburg	nl-ge-dos	nl,nl-ge,nl-fl,nl-zwo,nl-ge-elb,nl-ge-dos
Doorwerth	Renkum	nl-ge-dow	nl,nl-ge,nl-arn,nl-ede,nl-ge-rnk,nl-ge-dow
Drempt	Bronckhorst	nl-ge-dpt	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-dpt
Dreumel	West Maas en Waal	nl-ge-dum	nl,nl-ge,nl-nb,nl-oss,nl-ge-wmw,nl-ge-dum
Driel	Overbetuwe	nl-ge-drl	nl,nl-ge,nl-arn,nl-nij,nl-ede,nl-ge-qcu,nl-ge-drl
Druten	Druten	nl-ge-dru	nl,nl-ge,nl-nb,nl-ut,nl-oss,nl-ge-dru,nl-ge-dru
Duiven	Duiven	nl-ge-dui	nl,nl-ge,nl-arn,nl-ge-dui,nl-ge-dui
Echteld	Neder-Betuwe	nl-ge-ecd	nl,nl-ge,nl-ut,nl-nb,nl-oss,nl-ge-nbw,nl-ge-ecd
Eck en Wiel	Buren	nl-ge-ewi	nl,nl-ge,nl-ut,nl-ede,nl-ge-bur,nl-ge-ewi
Ede	Ede	nl-ge-ede	nl,nl-ge,nl-ut,nl-ede,nl-ge-ede,nl-ge-ede
Ederveen	Ede	nl-ge-evn	nl,nl-ge,nl-ut,nl-ede,nl-ge-ede,nl-ge-evn
Eefde	Lochem	nl-ge-efe	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch,nl-ge-efe
Eerbeek	Brummen	nl-ge-eee	nl,nl-ge,nl-ape,nl-ge-brm,nl-ge-eee
Eibergen	Berkelland	nl-ge-eib	nl,nl-ge,nl-ov,nl-hgl,nl-ge-kll,nl-ge-eib
Elburg	Elburg	nl-ge-elb	nl,nl-ge,nl-ov,nl-fl,nl-zwo,nl-ge-elb,nl-ge-elb
Ellecom	Rheden	nl-ge-ell	nl,nl-ge,nl-arn,nl-ge-rhd,nl-ge-ell
Elspeet	Nunspeet	nl-ge-elt	nl,nl-ge,nl-ape,nl-ge-nun,nl-ge-elt
Elst	Overbetuwe	nl-ge-qcu	nl,nl-ge,nl-nij,nl-arn,nl-ge-qcu,nl-ge-qcu
Empe	Brummen	nl-ge-emp	nl,nl-ge,nl-dev,nl-ape,nl-ge-brm,nl-ge-emp
Emst	Epe	nl-ge-zao	nl,nl-ge,nl-ov,nl-ape,nl-ge-epe,nl-ge-zao
Enspijk	West Betuwe	nl-ge-enp	nl,nl-ge,nl-ut,nl-htb,nl-utc,nl-ge-gdm,nl-ge-enp
Epe	Epe	nl-ge-epe	nl,nl-ge,nl-ov,nl-ape,nl-dev,nl-ge-epe,nl-ge-epe
Epse	Lochem	nl-ge-eps	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch,nl-ge-eps
Erichem	Buren	nl-ge-bur	nl,nl-ge,nl-ut,nl-oss,nl-ge-bur
Erlecom	Berg en Dal	nl-ge-zat	nl,nl-ge,nl-nij,nl-ge-zat
Ermelo	Ermelo	nl-ge-erm	nl,nl-ge,nl-fl,nl-ame,nl-ge-erm,nl-ge-erm
Est	West Betuwe	nl-ge-set	nl,nl-ge,nl-nb,nl-oss,nl-htb,nl-ge-gdm,nl-ge-set
Etten	Oude IJsselstreek	nl-ge-et2	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-et2
Ewijk	Beuningen	nl-ge-ewk	nl,nl-ge,nl-nb,nl-nij,nl-ge-bnn,nl-ge-ewk
Gaanderen	Doetinchem	nl-ge-aan	nl,nl-ge,nl-doi,nl-ge-doi,nl-ge-aan
Gameren	Zaltbommel	nl-ge-gam	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb,nl-ge-gam
Garderen	Barneveld	nl-ge-gar	nl,nl-ge,nl-ape,nl-ge-bar,nl-ge-gar
Geesteren	Berkelland	nl-ge-ges	nl,nl-ge,nl-ov,nl-hgl,nl-doi,nl-ge-kll,nl-ge-ges
Geldermalsen	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-oss,nl-htb,nl-ge-gdm,nl-ge-gdm
Gellicum	West Betuwe	nl-ge-gec	nl,nl-ge,nl-ut,nl-htb,nl-utc,nl-ge-gdm,nl-ge-gec
Gelselaar	Berkelland	nl-ge-kll	nl,nl-ge,nl-ov,nl-hgl,nl-alm,nl-ge-kll
Gendringen	Oude IJsselstreek	nl-ge-ggn	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-ggn
Gendt	Lingewaard	nl-ge-get	nl,nl-ge,nl-nij,nl-arn,nl-ge-lir,nl-ge-get
Giesbeek	Zevenaar	nl-ge-gib	nl,nl-ge,nl-arn,nl-ge-zev,nl-ge-gib
Gorssel	Lochem	nl-ge-esl	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch,nl-ge-esl
Groenlo	Oost Gelre	nl-ge-grn	nl,nl-ge,nl-doi,nl-ge-opt,nl-ge-grn
Groesbeek	Berg en Dal	nl-ge-zat	nl,nl-ge,nl-li,nl-nb,nl-nij,nl-ge-zat,nl-ge-zat
Groessen	Duiven	nl-ge-grs	nl,nl-ge,nl-arn,nl-ge-dui,nl-ge-grs
Haaften	West Betuwe	nl-ge-hfn	nl,nl-ge,nl-nb,nl-htb,nl-ge-gdm,nl-ge-hfn
Haalderen	Lingewaard	nl-ge-lir	nl,nl-ge,nl-nij,nl-arn,nl-ge-lir
Haarlo	Berkelland	nl-ge-arl	nl,nl-ge,nl-ov,nl-hgl,nl-ge-kll,nl-ge-arl
Hall	Brummen	nl-ge-brm	nl,nl-ge,nl-ape,nl-dev,nl-ge-brm
Halle	Bronckhorst	nl-ge-ale	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-ale
Harderwijk	Harderwijk	nl-ge-hrd	nl,nl-ge,nl-fl,nl-ley,nl-ge-hrd,nl-ge-hrd
Harfsen	Lochem	nl-ge-haf	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch,nl-ge-haf
Harreveld	Oost Gelre	nl-ge-hvl	nl,nl-ge,nl-doi,nl-ge-opt,nl-ge-hvl
Harskamp	Ede	nl-ge-hsk	nl,nl-ge,nl-ede,nl-ge-ede,nl-ge-hsk
Hattem	Hattem	nl-ge-htm	nl,nl-ge,nl-ov,nl-zwo,nl-ge-htm,nl-ge-htm
Hattemerbroek	Oldebroek	nl-ge-htk	nl,nl-ge,nl-ov,nl-zwo,nl-ge-olb,nl-ge-htk
Hedel	Maasdriel	nl-ge-hdg	nl,nl-ge,nl-nb,nl-htb,nl-ge-mdr,nl-ge-hdg
Heelsum	Renkum	nl-ge-hsu	nl,nl-ge,nl-ede,nl-arn,nl-ge-rnk,nl-ge-hsu
Heelweg	Oude IJsselstreek	nl-ge-oat	nl,nl-ge,nl-doi,nl-ge-oat
Heerde	Heerde	nl-ge-hde	nl,nl-ge,nl-ov,nl-zwo,nl-ge-hde,nl-ge-hde
Heerewaarden	Maasdriel	nl-ge-hrw	nl,nl-ge,nl-nb,nl-oss,nl-ge-mdr,nl-ge-hrw
Heesselt	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-nb,nl-oss,nl-htb,nl-ge-gdm
Heilig Landstichting	Berg en Dal	nl-ge-zat	nl,nl-ge,nl-li,nl-nb,nl-nij,nl-ge-zat
Hellouw	West Betuwe	nl-ge-huw	nl,nl-ge,nl-nb,nl-ut,nl-htb,nl-ge-gdm,nl-ge-huw
Hemmen	Overbetuwe	nl-ge-qcu	nl,nl-ge,nl-ut,nl-ede,nl-ge-qcu
Hengelo (Gld)	Bronckhorst	nl-ge-bck	nl,nl-ge,nl-doi,nl-ge-bck
Hernen	Wijchen	nl-ge-wch	nl,nl-ge,nl-nb,nl-nij,nl-oss,nl-ge-wch
Herveld	Overbetuwe	nl-ge-hvd	nl,nl-ge,nl-nij,nl-ge-qcu,nl-ge-hvd
Herwen	Zevenaar	nl-ge-zev	nl,nl-ge,nl-doi,nl-nij,nl-arn,nl-ge-zev
Herwijnen	West Betuwe	nl-ge-hwj	nl,nl-ge,nl-nb,nl-ut,nl-htb,nl-ge-gdm,nl-ge-hwj
Heteren	Overbetuwe	nl-ge-htr	nl,nl-ge,nl-arn,nl-ede,nl-ge-qcu,nl-ge-htr
Heukelum	West Betuwe	nl-ge-huk	nl,nl-ge,nl-ut,nl-zh,nl-utc,nl-htb,nl-ge-gdm,nl-ge-huk
Heumen	Heumen	nl-ge-hum	nl,nl-ge,nl-li,nl-nb,nl-nij,nl-ge-hum,nl-ge-hum
Heveadorp	Renkum	nl-ge-rnk	nl,nl-ge,nl-arn,nl-ede,nl-ge-rnk
Hierden	Harderwijk	nl-ge-hrd	nl,nl-ge,nl-fl,nl-ley,nl-ge-hrd
Hoenderloo	Ede	nl-ge-ede	nl,nl-ge,nl-ape,nl-ge-ede
Hoenderloo	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ape,nl-ge-ape
Hoenzadriel	Maasdriel	nl-ge-hzr	nl,nl-ge,nl-nb,nl-htb,nl-oss,nl-ge-mdr,nl-ge-hzr
Hoevelaken	Nijkerk	nl-ge-hoe	nl,nl-ge,nl-ut,nl-ame,nl-ge-nkk,nl-ge-hoe
Homoet	Overbetuwe	nl-ge-qcu	nl,nl-ge,nl-arn,nl-nij,nl-ge-qcu
Hoog Soeren	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ape,nl-ge-ape
Hoog-Keppel	Bronckhorst	nl-ge-bck	nl,nl-ge,nl-doi,nl-ge-bck
Horssen	Druten	nl-ge-hss	nl,nl-ge,nl-nb,nl-oss,nl-ge-dru,nl-ge-hss
Huissen	Lingewaard	nl-ge-hus	nl,nl-ge,nl-arn,nl-nij,nl-ge-lir,nl-ge-hus
Hulshorst	Nunspeet	nl-ge-osr	nl,nl-ge,nl-ape,nl-ley,nl-ge-nun,nl-ge-osr
Hummelo	Bronckhorst	nl-ge-hml	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-hml
Hurwenen	Maasdriel	nl-ge-mdr	nl,nl-ge,nl-nb,nl-htb,nl-ge-mdr
IJzendoorn	Neder-Betuwe	nl-ge-nbw	nl,nl-ge,nl-ut,nl-nb,nl-oss,nl-ge-nbw
Ingen	Buren	nl-ge-ing	nl,nl-ge,nl-ut,nl-ede,nl-ge-bur,nl-ge-ing
Joppe	Lochem	nl-ge-lch	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch
Kapel Avezaath	Tiel	nl-ge-tie	nl,nl-ge,nl-nb,nl-oss,nl-ge-tie
Kapel-Avezaath	Buren	nl-ge-kav	nl,nl-ge,nl-nb,nl-oss,nl-ge-bur,nl-ge-kav
Keijenborg	Bronckhorst	nl-ge-keb	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-keb
Kekerdom	Berg en Dal	nl-ge-kek	nl,nl-ge,nl-nij,nl-ge-zat,nl-ge-kek
Kerk Avezaath	Tiel	nl-ge-tie	nl,nl-ge,nl-ut,nl-oss,nl-ge-tie
Kerk-Avezaath	Buren	nl-ge-bur	nl,nl-ge,nl-ut,nl-oss,nl-ge-bur
Kerkdriel	Maasdriel	nl-ge-krd	nl,nl-ge,nl-nb,nl-htb,nl-oss,nl-ge-mdr,nl-ge-krd
Kerkwijk	Zaltbommel	nl-ge-kew	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb,nl-ge-kew
Kesteren	Neder-Betuwe	nl-ge-kst	nl,nl-ge,nl-ut,nl-ede,nl-ge-nbw,nl-ge-kst
Kilder	Montferland	nl-ge-mtl	nl,nl-ge,nl-doi,nl-ge-mtl
Klarenbeek	Voorst	nl-ge-kbk	nl,nl-ge,nl-ape,nl-dev,nl-ge-vrs,nl-ge-kbk
Klarenbeek	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ape,nl-dev,nl-ge-ape
Kootwijk	Barneveld	nl-ge-bar	nl,nl-ge,nl-ape,nl-ge-bar
Kootwijkerbroek	Barneveld	nl-ge-kw2	nl,nl-ge,nl-ede,nl-ge-bar,nl-ge-kw2
Kring van Dorth	Lochem	nl-ge-kdo	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch,nl-ge-kdo
Laag-Keppel	Bronckhorst	nl-ge-lgk	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-lgk
Laag-Soeren	Rheden	nl-ge-rhd	nl,nl-ge,nl-arn,nl-ape,nl-ge-rhd
Laren	Lochem	nl-ge-lar	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch,nl-ge-lar
Lathum	Zevenaar	nl-ge-ltu	nl,nl-ge,nl-arn,nl-ge-zev,nl-ge-ltu
Lengel	Montferland	nl-ge-mtl	nl,nl-ge,nl-doi,nl-ge-mtl
Lent	Nijmegen	nl-ge-lnt	nl,nl-ge,nl-nij,nl-arn,nl-ge-nij,nl-ge-lnt
Leur	Wijchen	nl-ge-wch	nl,nl-ge,nl-nb,nl-nij,nl-oss,nl-ge-wch
Leuth	Berg en Dal	nl-ge-lth	nl,nl-ge,nl-nij,nl-ge-zat,nl-ge-lth
Leuvenheim	Brummen	nl-ge-gel	nl,nl-ge,nl-doi,nl-ge-brm,nl-ge-gel
Lichtenvoorde	Oost Gelre	nl-ge-lcv	nl,nl-ge,nl-doi,nl-ge-opt,nl-ge-lcv
Lienden	Buren	nl-ge-lie	nl,nl-ge,nl-ut,nl-ede,nl-ge-bur,nl-ge-lie
Lieren	Apeldoorn	nl-ge-len	nl,nl-ge,nl-ape,nl-ge-ape,nl-ge-len
Lievelde	Oost Gelre	nl-ge-opt	nl,nl-ge,nl-doi,nl-ge-opt
Lobith	Zevenaar	nl-ge-lob	nl,nl-ge,nl-doi,nl-nij,nl-ge-zev,nl-ge-lob
Lochem	Lochem	nl-ge-lch	nl,nl-ge,nl-ov,nl-dev,nl-ge-lch,nl-ge-lch
Loenen	Apeldoorn	nl-ge-lon	nl,nl-ge,nl-ape,nl-ge-ape,nl-ge-lon
Loerbeek	Montferland	nl-ge-mtl	nl,nl-ge,nl-doi,nl-ge-mtl
Lunteren	Ede	nl-ge-ltn	nl,nl-ge,nl-ut,nl-ede,nl-ge-ede,nl-ge-ltn
Maasbommel	West Maas en Waal	nl-ge-wmw	nl,nl-ge,nl-nb,nl-oss,nl-ge-wmw
Malden	Heumen	nl-ge-mad	nl,nl-ge,nl-li,nl-nb,nl-nij,nl-ge-hum,nl-ge-mad
Mariënvelde	Oost Gelre	nl-ge-opt	nl,nl-ge,nl-doi,nl-ge-opt
Maurik	Buren	nl-ge-mau	nl,nl-ge,nl-ut,nl-ede,nl-ge-bur,nl-ge-mau
Megchelen	Oude IJsselstreek	nl-ge-meg	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-meg
Meteren	West Betuwe	nl-ge-ge7	nl,nl-ge,nl-htb,nl-oss,nl-ge-gdm,nl-ge-ge7
Millingen aan de Rijn	Berg en Dal	nl-ge-mlr	nl,nl-ge,nl-nij,nl-ge-zat,nl-ge-mlr
Nederasselt	Heumen	nl-ge-nst	nl,nl-ge,nl-nb,nl-li,nl-nij,nl-ge-hum,nl-ge-nst
Nederhemert	Zaltbommel	nl-ge-zba	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb,nl-ge-zba
Neede	Berkelland	nl-ge-nee	nl,nl-ge,nl-ov,nl-hgl,nl-ge-kll,nl-ge-nee
Neerijnen	West Betuwe	nl-ge-nej	nl,nl-ge,nl-nb,nl-htb,nl-ge-gdm,nl-ge-nej
Netterden	Oude IJsselstreek	nl-ge-ntd	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-ntd
Nieuwaal	Zaltbommel	nl-ge-zlb	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb
Niftrik	Wijchen	nl-ge-nfk	nl,nl-ge,nl-nb,nl-oss,nl-ge-wch,nl-ge-nfk
Nijbroek	Voorst	nl-ge-vrs	nl,nl-ge,nl-ov,nl-dev,nl-ape,nl-ge-vrs
Nijkerk	Nijkerk	nl-ge-nkk	nl,nl-ge,nl-ut,nl-ame,nl-ge-nkk,nl-ge-nkk
Nijkerkerveen	Nijkerk	nl-ge-nkv	nl,nl-ge,nl-ut,nl-ame,nl-ge-nkk,nl-ge-nkv
Nijmegen	Nijmegen	nl-ge-nij	nl,nl-ge,nl-li,nl-nij,nl-ge-nij,nl-ge-nij
Noordeinde Gld	Oldebroek	nl-ge-olb	nl,nl-ge,nl-ov,nl-zwo,nl-ge-olb
Nunspeet	Nunspeet	nl-ge-nun	nl,nl-ge,nl-ape,nl-ge-nun,nl-ge-nun
Ochten	Neder-Betuwe	nl-ge-occ	nl,nl-ge,nl-ut,nl-nb,nl-oss,nl-ede,nl-ge-nbw,nl-ge-occ
Oene	Epe	nl-ge-epe	nl,nl-ge,nl-ov,nl-dev,nl-ge-epe
Olburgen	Bronckhorst	nl-ge-obe	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-obe
Oldebroek	Oldebroek	nl-ge-olb	nl,nl-ge,nl-ov,nl-zwo,nl-ge-olb,nl-ge-olb
Ommeren	Buren	nl-ge-ore	nl,nl-ge,nl-ut,nl-ede,nl-ge-bur,nl-ge-ore
Ooij	Berg en Dal	nl-ge-ooy	nl,nl-ge,nl-nij,nl-ge-zat,nl-ge-ooy
Oosterbeek	Renkum	nl-ge-osb	nl,nl-ge,nl-arn,nl-ede,nl-ge-rnk,nl-ge-osb
Oosterhout	Overbetuwe	nl-ge-oth	nl,nl-ge,nl-nij,nl-arn,nl-ge-qcu,nl-ge-oth
Oosterwolde Gld	Oldebroek	nl-ge-olb	nl,nl-ge,nl-ov,nl-zwo,nl-ge-olb
Ophemert	West Betuwe	nl-ge-oph	nl,nl-ge,nl-nb,nl-oss,nl-ge-gdm,nl-ge-oph
Opheusden	Neder-Betuwe	nl-ge-opd	nl,nl-ge,nl-ut,nl-ede,nl-ge-nbw,nl-ge-opd
Opijnen	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-nb,nl-htb,nl-oss,nl-ge-gdm
Otterlo	Ede	nl-ge-ede	nl,nl-ge,nl-ede,nl-ge-ede
Overasselt	Heumen	nl-ge-oas	nl,nl-ge,nl-nb,nl-li,nl-nij,nl-ge-hum,nl-ge-oas
Pannerden	Zevenaar	nl-ge-pnn	nl,nl-ge,nl-nij,nl-arn,nl-ge-zev,nl-ge-pnn
Persingen	Berg en Dal	nl-ge-zat	nl,nl-ge,nl-li,nl-nij,nl-ge-zat
Poederoijen	Zaltbommel	nl-ge-pdj	nl,nl-ge,nl-nb,nl-zh,nl-htb,nl-ge-zlb,nl-ge-pdj
Puiflijk	Druten	nl-ge-dru	nl,nl-ge,nl-nb,nl-ut,nl-oss,nl-ge-dru
Putten	Putten	nl-ge-ptn	nl,nl-ge,nl-fl,nl-ame,nl-ge-ptn,nl-ge-ptn
Radio Kootwijk	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ape,nl-ge-ape
Randwijk	Overbetuwe	nl-ge-qcu	nl,nl-ge,nl-ut,nl-ede,nl-ge-qcu
Ravenswaaij	Buren	nl-ge-bur	nl,nl-ge,nl-ut,nl-utc,nl-ge-bur
Rekken	Berkelland	nl-ge-kll	nl,nl-ge,nl-ov,nl-hgl,nl-ge-kll
Renkum	Renkum	nl-ge-rnk	nl,nl-ge,nl-ede,nl-arn,nl-ge-rnk,nl-ge-rnk
Ressen	Lingewaard	nl-ge-nld	nl,nl-ge,nl-nij,nl-arn,nl-ge-lir,nl-ge-nld
Rha	Bronckhorst	nl-ge-bck	nl,nl-ge,nl-doi,nl-ge-bck
Rheden	Rheden	nl-ge-rhd	nl,nl-ge,nl-arn,nl-ge-rhd,nl-ge-rhd
Rhenoy	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-ut,nl-utc,nl-htb,nl-ge-gdm
Rietmolen	Berkelland	nl-ge-kll	nl,nl-ge,nl-ov,nl-hgl,nl-ge-kll
Rijswijk (GLD)	Buren	nl-ge-bur	nl,nl-ge,nl-ut,nl-utc,nl-ame,nl-ede,nl-oss,nl-ge-bur
Rossum	Maasdriel	nl-ge-grm	nl,nl-ge,nl-nb,nl-htb,nl-oss,nl-ge-mdr,nl-ge-grm
Rozendaal	Rozendaal	nl-ge-rzd	nl,nl-ge,nl-arn,nl-ge-rzd,nl-ge-rzd
Rumpt	West Betuwe	nl-ge-rum	nl,nl-ge,nl-ut,nl-utc,nl-htb,nl-ge-gdm,nl-ge-rum
Ruurlo	Berkelland	nl-ge-rro	nl,nl-ge,nl-doi,nl-ge-kll,nl-ge-rro
Scherpenzeel	Scherpenzeel	nl-ge-srp	nl,nl-ge,nl-ut,nl-ame,nl-ede,nl-ge-srp,nl-ge-srp
Silvolde	Oude IJsselstreek	nl-ge-siv	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-siv
Sinderen	Oude IJsselstreek	nl-ge-oat	nl,nl-ge,nl-doi,nl-ge-oat
Slijk-Ewijk	Overbetuwe	nl-ge-qcu	nl,nl-ge,nl-nij,nl-arn,nl-ge-qcu
Spankeren	Rheden	nl-ge-rhd	nl,nl-ge,nl-doi,nl-arn,nl-ge-rhd
Spijk	West Betuwe	nl-ge-sjk	nl,nl-ge,nl-zh,nl-ut,nl-dor,nl-ge-gdm,nl-ge-sjk
Steenderen	Bronckhorst	nl-ge-sdn	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-sdn
Steenenkamer	Voorst	nl-ge-vrs	nl,nl-ge,nl-ov,nl-dev,nl-ape,nl-ge-vrs
Stokkum	Montferland	nl-ge-mtl	nl,nl-ge,nl-doi,nl-ge-mtl
Stroe	Barneveld	nl-ge-srt	nl,nl-ge,nl-ede,nl-ge-bar,nl-ge-srt
Terborg	Oude IJsselstreek	nl-ge-tbo	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-tbo
Terschuur	Barneveld	nl-ge-teu	nl,nl-ge,nl-ut,nl-ame,nl-ge-bar,nl-ge-teu
Terwolde	Voorst	nl-ge-trw	nl,nl-ge,nl-ov,nl-dev,nl-ape,nl-ge-vrs,nl-ge-trw
Teuge	Voorst	nl-ge-tge	nl,nl-ge,nl-ov,nl-ape,nl-dev,nl-ge-vrs,nl-ge-tge
Tiel	Tiel	nl-ge-tie	nl,nl-ge,nl-nb,nl-oss,nl-ge-tie,nl-ge-tie
Toldijk	Bronckhorst	nl-ge-tld	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-tld
Tolkamer	Zevenaar	nl-ge-tkm	nl,nl-ge,nl-nij,nl-doi,nl-ge-zev,nl-ge-tkm
Tonden	Brummen	nl-ge-brm	nl,nl-ge,nl-dev,nl-ge-brm
Tricht	West Betuwe	nl-ge-trc	nl,nl-ge,nl-oss,nl-htb,nl-ge-gdm,nl-ge-trc
Tuil	West Betuwe	nl-ge-tul	nl,nl-ge,nl-htb,nl-ge-gdm,nl-ge-tul
Twello	Voorst	nl-ge-twe	nl,nl-ge,nl-ov,nl-dev,nl-ape,nl-ge-vrs,nl-ge-twe
Ubbergen	Berg en Dal	nl-ge-zat	nl,nl-ge,nl-li,nl-nb,nl-nij,nl-ge-zat
Uddel	Apeldoorn	nl-ge-udl	nl,nl-ge,nl-ape,nl-ge-ape,nl-ge-udl
Ugchelen	Apeldoorn	nl-ge-zds	nl,nl-ge,nl-ape,nl-ge-ape,nl-ge-zds
Ulft	Oude IJsselstreek	nl-ge-ulf	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-ulf
Vaassen	Epe	nl-ge-vaa	nl,nl-ge,nl-ov,nl-ape,nl-dev,nl-ge-epe,nl-ge-vaa
Valburg	Overbetuwe	nl-ge-qcu	nl,nl-ge,nl-nij,nl-arn,nl-ge-qcu
Varik	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-nb,nl-oss,nl-ge-gdm
Varsselder	Oude IJsselstreek	nl-ge-oat	nl,nl-ge,nl-doi,nl-ge-oat
Varsseveld	Oude IJsselstreek	nl-ge-vsr	nl,nl-ge,nl-doi,nl-ge-oat,nl-ge-vsr
Veessen	Heerde	nl-ge-hde	nl,nl-ge,nl-ov,nl-dev,nl-zwo,nl-ge-hde
Velddriel	Maasdriel	nl-ge-d6d	nl,nl-ge,nl-nb,nl-htb,nl-ge-mdr,nl-ge-d6d
Velp	Rheden	nl-ge-vep	nl,nl-ge,nl-arn,nl-ge-rhd,nl-ge-vep
Vethuizen	Montferland	nl-ge-mtl	nl,nl-ge,nl-doi,nl-ge-mtl
Vierakker	Bronckhorst	nl-ge-vkk	nl,nl-ge,nl-doi,nl-dev,nl-ge-bck,nl-ge-vkk
Vierhouten	Nunspeet	nl-ge-vht	nl,nl-ge,nl-ape,nl-ge-nun,nl-ge-vht
Voorst	Voorst	nl-ge-vrs	nl,nl-ge,nl-ov,nl-dev,nl-ape,nl-ge-vrs,nl-ge-vrs
Voorthuizen	Barneveld	nl-ge-vhz	nl,nl-ge,nl-ut,nl-ame,nl-ede,nl-ge-bar,nl-ge-vhz
Vorchten	Heerde	nl-ge-hde	nl,nl-ge,nl-ov,nl-zwo,nl-ge-hde
Vorden	Bronckhorst	nl-ge-vfr	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-vfr
Vragender	Oost Gelre	nl-ge-vgr	nl,nl-ge,nl-doi,nl-ge-opt,nl-ge-vgr
Vuren	West Betuwe	nl-ge-vrn	nl,nl-ge,nl-zh,nl-nb,nl-htb,nl-ge-gdm,nl-ge-vrn
Waardenburg	West Betuwe	nl-ge-wdn	nl,nl-ge,nl-nb,nl-htb,nl-ge-gdm,nl-ge-wdn
Wadenoijen	Tiel	nl-ge-tie	nl,nl-ge,nl-nb,nl-oss,nl-ge-tie
Wageningen	Wageningen	nl-ge-wgw	nl,nl-ge,nl-ut,nl-ede,nl-ge-wgw,nl-ge-wgw
Wamel	West Maas en Waal	nl-ge-wxm	nl,nl-ge,nl-nb,nl-oss,nl-ge-wmw,nl-ge-wxm
Wapenveld	Heerde	nl-ge-wap	nl,nl-ge,nl-ov,nl-zwo,nl-ge-hde,nl-ge-wap
Warnsveld	Zutphen	nl-ge-war	nl,nl-ge,nl-dev,nl-ge-zut,nl-ge-war
Wehl	Doetinchem	nl-ge-whl	nl,nl-ge,nl-doi,nl-ge-doi,nl-ge-whl
Wekerom	Ede	nl-ge-wko	nl,nl-ge,nl-ede,nl-ge-ede,nl-ge-wko
Well	Maasdriel	nl-ge-wel	nl,nl-ge,nl-nb,nl-htb,nl-ge-mdr,nl-ge-wel
Wenum Wiesel	Apeldoorn	nl-ge-ape	nl,nl-ge,nl-ape,nl-ge-ape
Westendorp	Oude IJsselstreek	nl-ge-oat	nl,nl-ge,nl-doi,nl-ge-oat
Westervoort	Westervoort	nl-ge-wev	nl,nl-ge,nl-arn,nl-ge-wev,nl-ge-wev
Weurt	Beuningen	nl-ge-weu	nl,nl-ge,nl-nij,nl-ge-bnn,nl-ge-weu
Wezep	Oldebroek	nl-ge-wzp	nl,nl-ge,nl-ov,nl-zwo,nl-ge-olb,nl-ge-wzp
Wichmond	Bronckhorst	nl-ge-bck	nl,nl-ge,nl-doi,nl-ge-bck
Wijchen	Wijchen	nl-ge-wch	nl,nl-ge,nl-nb,nl-nij,nl-ge-wch,nl-ge-wch
Wijnbergen	Montferland	nl-ge-wig	nl,nl-ge,nl-doi,nl-ge-mtl,nl-ge-wig
Wilp	Voorst	nl-ge-wil	nl,nl-ge,nl-ov,nl-dev,nl-ape,nl-ge-vrs,nl-ge-wil
Winssen	Beuningen	nl-ge-wsn	nl,nl-ge,nl-nb,nl-nij,nl-ge-bnn,nl-ge-wsn
Winterswijk	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-doi,nl-ge-wtw,nl-ge-wtw
Winterswijk Brinkheurne	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-doi,nl-ge-wtw
Winterswijk Corle	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-doi,nl-ge-wtw
Winterswijk Henxel	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-hgl,nl-doi,nl-ge-wtw
Winterswijk Huppel	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-hgl,nl-doi,nl-ge-wtw
Winterswijk Kotten	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-doi,nl-hgl,nl-ge-wtw
Winterswijk Meddo	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-hgl,nl-doi,nl-ge-wtw
Winterswijk Miste	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-doi,nl-ge-wtw
Winterswijk Ratum	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-hgl,nl-doi,nl-ge-wtw
Winterswijk Woold	Winterswijk	nl-ge-wtw	nl,nl-ge,nl-doi,nl-ge-wtw
Wolfheze	Renkum	nl-ge-wol	nl,nl-ge,nl-arn,nl-ede,nl-ge-rnk,nl-ge-wol
Zaltbommel	Zaltbommel	nl-ge-zlb	nl,nl-ge,nl-nb,nl-htb,nl-ge-zlb,nl-ge-zlb
Zeddam	Montferland	nl-ge-zdm	nl,nl-ge,nl-doi,nl-ge-mtl,nl-ge-zdm
Zelhem	Bronckhorst	nl-ge-zem	nl,nl-ge,nl-doi,nl-ge-bck,nl-ge-zem
Zennewijnen	Tiel	nl-ge-tie	nl,nl-ge,nl-nb,nl-oss,nl-ge-tie
Zennewijnen	West Betuwe	nl-ge-gdm	nl,nl-ge,nl-nb,nl-oss,nl-ge-gdm
Zetten	Overbetuwe	nl-ge-zet	nl,nl-ge,nl-ede,nl-nij,nl-ge-qcu,nl-ge-zet
Zevenaar	Zevenaar	nl-ge-zev	nl,nl-ge,nl-arn,nl-ge-zev,nl-ge-zev
Zieuwent	Oost Gelre	nl-ge-opt	nl,nl-ge,nl-doi,nl-ge-opt
Zoelen	Buren	nl-ge-zoe	nl,nl-ge,nl-ut,nl-oss,nl-ge-bur,nl-ge-zoe
Zoelmond	Buren	nl-ge-bur	nl,nl-ge,nl-ut,nl-utc,nl-ge-bur
Zuilichem	Zaltbommel	nl-ge-zch	nl,nl-ge,nl-nb,nl-ut,nl-htb,nl-ge-zlb,nl-ge-zch
Zutphen	Zutphen	nl-ge-zut	nl,nl-ge,nl-dev,nl-ge-zut,nl-ge-zut
Zwartebroek	Barneveld	nl-ge-zbr	nl,nl-ge,nl-ut,nl-ame,nl-ge-bar,nl-ge-zbr
't Goy	Houten	nl-ut-goy	nl,nl-ut,nl-ge,nl-utc,nl-ut-hou,nl-ut-goy
Abcoude	De Ronde Venen	nl-ut-abc	nl,nl-ut,nl-nh,nl-ams,nl-ut-rve,nl-ut-abc
Achterveld	Leusden	nl-ut-ach	nl,nl-ut,nl-ge,nl-ame,nl-ut-leu,nl-ut-ach
Ameide	Vijfheerenlanden	nl-ut-aed	nl,nl-ut,nl-zh,nl-utc,nl-ut-van,nl-ut-aed
Amerongen	Utrechtse Heuvelrug	nl-ut-amr	nl,nl-ut,nl-ge,nl-ede,nl-ut-drb,nl-ut-amr
Amersfoort	Amersfoort	nl-ut-ame	nl,nl-ut,nl-ge,nl-ame,nl-ut-ame,nl-ut-ame
Amstelhoek	De Ronde Venen	nl-ut-alh	nl,nl-ut,nl-nh,nl-zh,nl-ams,nl-ut-rve,nl-ut-alh
Austerlitz	Zeist	nl-ut-zit	nl,nl-ut,nl-ame,nl-utc,nl-ut-zit
Baambrugge	De Ronde Venen	nl-ut-bge	nl,nl-ut,nl-nh,nl-ams,nl-ut-rve,nl-ut-bge
Baarn	Baarn	nl-ut-baa	nl,nl-ut,nl-nh,nl-ame,nl-ut-baa,nl-ut-baa
Benschop	Lopik	nl-ut-hop	nl,nl-ut,nl-zh,nl-utc,nl-ut-lpk,nl-ut-hop
Bilthoven	De Bilt	nl-ut-bhv	nl,nl-ut,nl-nh,nl-utc,nl-ame,nl-ut-dbi,nl-ut-bhv
Bosch en Duin	Zeist	nl-ut-utb	nl,nl-ut,nl-utc,nl-ame,nl-ut-zit,nl-ut-utb
Breukelen	Stichtse Vecht	nl-ut-ruk	nl,nl-ut,nl-nh,nl-zh,nl-utc,nl-ut-svt,nl-ut-ruk
Bunnik	Bunnik	nl-ut-buk	nl,nl-ut,nl-utc,nl-ut-buk,nl-ut-buk
Bunschoten-Spakenburg	Bunschoten	nl-ut-bsb	nl,nl-ut,nl-ge,nl-nh,nl-ame,nl-ut-bun,nl-ut-bsb
Cothen	Wijk bij Duurstede	nl-ut-cot	nl,nl-ut,nl-ge,nl-utc,nl-ut-wbd,nl-ut-cot
De Bilt	De Bilt	nl-ut-dbi	nl,nl-ut,nl-utc,nl-ut-dbi,nl-ut-dbi
de Hoef	De Ronde Venen	nl-ut-deh	nl,nl-ut,nl-zh,nl-nh,nl-ams,nl-ut-rve,nl-ut-deh
De Meern	Utrecht	nl-ut-dem	nl,nl-ut,nl-utc,nl-ut-utc,nl-ut-dem
Den Dolder	Zeist	nl-ut-ddo	nl,nl-ut,nl-nh,nl-utc,nl-ame,nl-ut-zit,nl-ut-ddo
Doorn	Utrechtse Heuvelrug	nl-ut-doo	nl,nl-ut,nl-ge,nl-ame,nl-ut-drb,nl-ut-doo
Driebergen-Rijsenburg	Utrechtse Heuvelrug	nl-ut-drb	nl,nl-ut,nl-utc,nl-ame,nl-ut-drb,nl-ut-drb
Eemdijk	Bunschoten	nl-ut-ejk	nl,nl-ut,nl-nh,nl-ame,nl-ut-bun,nl-ut-ejk
Eemnes	Eemnes	nl-ut-ees	nl,nl-ut,nl-nh,nl-aer,nl-ame,nl-ut-ees,nl-ut-ees
Elst Ut	Rhenen	nl-ut-rhe	nl,nl-ut,nl-ge,nl-ede,nl-ut-rhe
Everdingen	Vijfheerenlanden	nl-ut-evd	nl,nl-ut,nl-ge,nl-utc,nl-ut-van,nl-ut-evd
Groenekan	De Bilt	nl-ut-gnk	nl,nl-ut,nl-nh,nl-utc,nl-ut-dbi,nl-ut-gnk
Haarzuilens	Utrecht	nl-ut-hzs	nl,nl-ut,nl-nh,nl-zh,nl-utc,nl-ut-utc,nl-ut-hzs
Hagestein	Vijfheerenlanden	nl-ut-hsn	nl,nl-ut,nl-ge,nl-utc,nl-ut-van,nl-ut-hsn
Harmelen	Woerden	nl-ut-ham	nl,nl-ut,nl-zh,nl-utc,nl-ut-wor,nl-ut-ham
Hei- en Boeicop	Vijfheerenlanden	nl-ut-heb	nl,nl-ut,nl-ge,nl-utc,nl-ut-van,nl-ut-heb
Hekendorp	Oudewater	nl-ut-hko	nl,nl-ut,nl-zh,nl-utc,nl-dor,nl-rtm,nl-ut-odw,nl-ut-hko
Hoef en Haag	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-ge,nl-utc,nl-ut-van
Hollandsche Rading	De Bilt	nl-ut-dbi	nl,nl-ut,nl-nh,nl-utc,nl-ut-dbi
Hoogland	Amersfoort	nl-ut-hol	nl,nl-ut,nl-ge,nl-ame,nl-ut-ame,nl-ut-hol
Hooglanderveen	Amersfoort	nl-ut-hog	nl,nl-ut,nl-ge,nl-ame,nl-ut-ame,nl-ut-hog
Houten	Houten	nl-ut-hou	nl,nl-ut,nl-ge,nl-utc,nl-ut-hou,nl-ut-hou
Huis ter Heide	Zeist	nl-ut-hth	nl,nl-ut,nl-utc,nl-ame,nl-ut-zit,nl-ut-hth
IJsselstein	IJsselstein	nl-ut-iji	nl,nl-ut,nl-utc,nl-ut-iji,nl-ut-iji
Jaarsveld	Lopik	nl-ut-lpk	nl,nl-ut,nl-zh,nl-utc,nl-ut-lpk
Kamerik	Woerden	nl-ut-kmr	nl,nl-ut,nl-zh,nl-utc,nl-ut-wor,nl-ut-kmr
Kedichem	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-ge,nl-zh,nl-htb,nl-utc,nl-dor,nl-ut-van
Kockengen	Stichtse Vecht	nl-ut-svt	nl,nl-ut,nl-zh,nl-nh,nl-utc,nl-ut-svt
Lage Vuursche	Baarn	nl-ut-baa	nl,nl-ut,nl-nh,nl-ame,nl-utc,nl-ut-baa
Langbroek	Wijk bij Duurstede	nl-ut-lak	nl,nl-ut,nl-ge,nl-utc,nl-ame,nl-ut-wbd,nl-ut-lak
Leerbroek	Vijfheerenlanden	nl-ut-lrb	nl,nl-ut,nl-ge,nl-zh,nl-utc,nl-ut-van,nl-ut-lrb
Leerdam	Vijfheerenlanden	nl-ut-lrd	nl,nl-ut,nl-ge,nl-zh,nl-utc,nl-ut-van,nl-ut-lrd
Leersum	Utrechtse Heuvelrug	nl-ut-ler	nl,nl-ut,nl-ge,nl-ame,nl-ede,nl-ut-drb,nl-ut-ler
Leusden	Leusden	nl-ut-leu	nl,nl-ut,nl-ge,nl-ame,nl-ut-leu,nl-ut-leu
Lexmond	Vijfheerenlanden	nl-ut-lxm	nl,nl-ut,nl-zh,nl-utc,nl-ut-van,nl-ut-lxm
Linschoten	Montfoort	nl-ut-lsc	nl,nl-ut,nl-zh,nl-utc,nl-ut-mnt,nl-ut-lsc
Loenen aan de Vecht	Stichtse Vecht	nl-ut-lav	nl,nl-ut,nl-nh,nl-utc,nl-ut-svt,nl-ut-lav
Loenersloot	Stichtse Vecht	nl-ut-lno	nl,nl-ut,nl-nh,nl-ams,nl-utc,nl-ut-svt,nl-ut-lno
Lopik	Lopik	nl-ut-lpk	nl,nl-ut,nl-zh,nl-utc,nl-ut-lpk,nl-ut-lpk
Lopikerkapel	Lopik	nl-ut-lkl	nl,nl-ut,nl-utc,nl-ut-lpk,nl-ut-lkl
Maarn	Utrechtse Heuvelrug	nl-ut-mav	nl,nl-ut,nl-ge,nl-ame,nl-ut-drb,nl-ut-mav
Maarsbergen	Utrechtse Heuvelrug	nl-ut-mab	nl,nl-ut,nl-ge,nl-ame,nl-ut-drb,nl-ut-mab
Maarssen	Stichtse Vecht	nl-ut-mss	nl,nl-ut,nl-nh,nl-utc,nl-ut-svt,nl-ut-mss
Maartensdijk	De Bilt	nl-ut-mrt	nl,nl-ut,nl-nh,nl-utc,nl-ut-dbi,nl-ut-mrt
Meerkerk	Vijfheerenlanden	nl-ut-mkk	nl,nl-ut,nl-zh,nl-ge,nl-utc,nl-ut-van,nl-ut-mkk
Mijdrecht	De Ronde Venen	nl-ut-mij	nl,nl-ut,nl-nh,nl-zh,nl-ams,nl-ut-rve,nl-ut-mij
Montfoort	Montfoort	nl-ut-mnt	nl,nl-ut,nl-zh,nl-utc,nl-ut-mnt,nl-ut-mnt
Nieuwegein	Nieuwegein	nl-ut-nwg	nl,nl-ut,nl-utc,nl-ut-nwg,nl-ut-nwg
Nieuwer Ter Aa	Stichtse Vecht	nl-ut-svt	nl,nl-ut,nl-nh,nl-zh,nl-utc,nl-ut-svt
Nieuwersluis	Stichtse Vecht	nl-ut-svt	nl,nl-ut,nl-nh,nl-utc,nl-ut-svt
Nieuwland	Vijfheerenlanden	nl-ut-nuw	nl,nl-ut,nl-zh,nl-ge,nl-utc,nl-ut-van,nl-ut-nuw
Nigtevecht	Stichtse Vecht	nl-ut-ngv	nl,nl-ut,nl-nh,nl-ams,nl-ut-svt,nl-ut-ngv
Odijk	Bunnik	nl-ut-odk	nl,nl-ut,nl-ge,nl-utc,nl-ut-buk,nl-ut-odk
Oosterwijk	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-ge,nl-zh,nl-utc,nl-htb,nl-ut-van
Ossenwaard	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-ge,nl-utc,nl-ut-van
Oud Zuilen	Stichtse Vecht	nl-ut-svt	nl,nl-ut,nl-nh,nl-utc,nl-ut-svt
Oudewater	Oudewater	nl-ut-odw	nl,nl-ut,nl-zh,nl-utc,nl-ut-odw,nl-ut-odw
Overberg	Utrechtse Heuvelrug	nl-ut-ovg	nl,nl-ut,nl-ge,nl-ede,nl-ut-drb,nl-ut-ovg
Papekop	Oudewater	nl-ut-odw	nl,nl-ut,nl-zh,nl-utc,nl-ut-odw
Polsbroek	Lopik	nl-ut-utp	nl,nl-ut,nl-zh,nl-utc,nl-dor,nl-ut-lpk,nl-ut-utp
Renswoude	Renswoude	nl-ut-rwd	nl,nl-ut,nl-ge,nl-ede,nl-ame,nl-ut-rwd,nl-ut-rwd
Rhenen	Rhenen	nl-ut-rhe	nl,nl-ut,nl-ge,nl-ede,nl-ut-rhe,nl-ut-rhe
Schalkwijk	Houten	nl-ut-skw	nl,nl-ut,nl-ge,nl-utc,nl-ut-hou,nl-ut-skw
Schoonrewoerd	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-ge,nl-utc,nl-ut-van
Snelrewaard	Oudewater	nl-ut-snw	nl,nl-ut,nl-zh,nl-utc,nl-ut-odw,nl-ut-snw
Soest	Soest	nl-ut-soe	nl,nl-ut,nl-nh,nl-ame,nl-ut-soe,nl-ut-soe
Soesterberg	Soest	nl-ut-sos	nl,nl-ut,nl-ame,nl-utc,nl-ut-soe,nl-ut-sos
Stoutenburg	Leusden	nl-ut-leu	nl,nl-ut,nl-ge,nl-ame,nl-ut-leu
Stoutenburg Noord	Amersfoort	nl-ut-ame	nl,nl-ut,nl-ge,nl-ame,nl-ut-ame
Tienhoven	Stichtse Vecht	nl-ut-svt	nl,nl-ut,nl-nh,nl-utc,nl-ut-svt
Tienhoven aan de Lek	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-zh,nl-utc,nl-ut-van
Tull en 't Waal	Houten	nl-ut-hou	nl,nl-ut,nl-ge,nl-utc,nl-ut-hou
Utrecht	Utrecht	nl-ut-utc	nl,nl-ut,nl-utc,nl-ut-utc,nl-ut-utc
Veenendaal	Veenendaal	nl-ut-vee	nl,nl-ut,nl-ge,nl-ede,nl-ut-vee,nl-ut-vee
Vianen	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-ge,nl-utc,nl-ut-van,nl-ut-van
Vinkeveen	De Ronde Venen	nl-ut-viv	nl,nl-ut,nl-nh,nl-zh,nl-ams,nl-utc,nl-ut-rve,nl-ut-viv
Vleuten	Utrecht	nl-ut-vlt	nl,nl-ut,nl-nh,nl-utc,nl-ut-utc,nl-ut-vlt
Vreeland	Stichtse Vecht	nl-ut-vrd	nl,nl-ut,nl-nh,nl-utc,nl-ut-svt,nl-ut-vrd
Waverveen	De Ronde Venen	nl-ut-rve	nl,nl-ut,nl-nh,nl-zh,nl-ams,nl-ut-rve
Werkhoven	Bunnik	nl-ut-wer	nl,nl-ut,nl-ge,nl-utc,nl-ut-buk,nl-ut-wer
Westbroek	De Bilt	nl-ut-wbo	nl,nl-ut,nl-nh,nl-utc,nl-ut-dbi,nl-ut-wbo
Wijk bij Duurstede	Wijk bij Duurstede	nl-ut-wbd	nl,nl-ut,nl-ge,nl-utc,nl-ame,nl-ut-wbd,nl-ut-wbd
Wilnis	De Ronde Venen	nl-ut-wln	nl,nl-ut,nl-zh,nl-nh,nl-utc,nl-ams,nl-ut-rve,nl-ut-wln
Woerden	Woerden	nl-ut-wor	nl,nl-ut,nl-zh,nl-utc,nl-ut-wor,nl-ut-wor
Woudenberg	Woudenberg	nl-ut-wdb	nl,nl-ut,nl-ge,nl-ame,nl-ut-wdb,nl-ut-wdb
Zegveld	Woerden	nl-ut-wor	nl,nl-ut,nl-zh,nl-utc,nl-ut-wor
Zeist	Zeist	nl-ut-zit	nl,nl-ut,nl-utc,nl-ame,nl-ut-zit,nl-ut-zit
Zijderveld	Vijfheerenlanden	nl-ut-van	nl,nl-ut,nl-ge,nl-utc,nl-ut-van
's-Graveland	Wijdemeren	nl-nh-sgl	nl,nl-nh,nl-ut,nl-aer,nl-utc,nl-nh-wim,nl-nh-sgl
't Veld	Hollands Kroon	nl-nh-vet	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-vet
't Zand	Schagen	nl-nh-tza	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-tza
Aalsmeer	Aalsmeer	nl-nh-aam	nl,nl-nh,nl-zh,nl-ut,nl-ams,nl-haa,nl-nh-aam,nl-nh-aam
Aalsmeerderbrug	Haarlemmermeer	nl-nh-amb	nl,nl-nh,nl-zh,nl-ut,nl-ams,nl-haa,nl-nh-hmm,nl-nh-amb
Aartswoud	Opmeer	nl-nh-zbq	nl,nl-nh,nl-hhw,nl-nh-zbq
Abbekerk	Medemblik	nl-nh-abb	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-abb
Abbenes	Haarlemmermeer	nl-nh-abe	nl,nl-nh,nl-zh,nl-lid,nl-nh-hmm,nl-nh-abe
Aerdenhout	Bloemendaal	nl-nh-aeh	nl,nl-nh,nl-zh,nl-haa,nl-nh-bmd,nl-nh-aeh
Akersloot	Castricum	nl-nh-akl	nl,nl-nh,nl-hhw,nl-nh-cas,nl-nh-akl
Alkmaar	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-alk
Amstelveen	Amstelveen	nl-nh-amv	nl,nl-nh,nl-ut,nl-zh,nl-ams,nl-nh-amv,nl-nh-amv
Amsterdam	Amsterdam	nl-nh-ams	nl,nl-nh,nl-ams,nl-nh-ams,nl-nh-ams
Amsterdam-Duivendrecht	Ouder-Amstel	nl-nh-odr	nl,nl-nh,nl-ams,nl-nh-odr
Andijk	Medemblik	nl-nh-aij	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-aij
Ankeveen	Wijdemeren	nl-nh-wim	nl,nl-nh,nl-ut,nl-aer,nl-nh-wim
Anna Paulowna	Hollands Kroon	nl-nh-anp	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-anp
Assendelft	Zaanstad	nl-nh-asd	nl,nl-nh,nl-haa,nl-nh-zst,nl-nh-asd
Avenhorn	Koggenland	nl-nh-ave	nl,nl-nh,nl-hhw,nl-nh-kol,nl-nh-ave
Badhoevedorp	Haarlemmermeer	nl-nh-bad	nl,nl-nh,nl-ams,nl-haa,nl-nh-hmm,nl-nh-bad
Barsingerhorn	Hollands Kroon	nl-nh-bgo	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-bgo
Beets	Edam-Volendam	nl-nh-bts	nl,nl-nh,nl-hhw,nl-nh-evo,nl-nh-bts
Beinsdorp	Haarlemmermeer	nl-nh-bsp	nl,nl-nh,nl-zh,nl-haa,nl-nh-hmm,nl-nh-bsp
Bennebroek	Bloemendaal	nl-nh-beb	nl,nl-nh,nl-zh,nl-haa,nl-nh-bmd,nl-nh-beb
Benningbroek	Medemblik	nl-nh-bbk	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-bbk
Bentveld	Zandvoort	nl-nh-ben	nl,nl-nh,nl-zh,nl-haa,nl-nh-zdv,nl-nh-ben
Bergen (NH)	Bergen (NH)	nl-nh-bgn	nl,nl-nh,nl-hhw,nl-nh-bgn
Bergen aan Zee	Bergen (NH)	nl-nh-beg	nl,nl-nh,nl-hhw,nl-nh-bgn,nl-nh-beg
Berkhout	Koggenland	nl-nh-bkt	nl,nl-nh,nl-hhw,nl-nh-kol,nl-nh-bkt
Beverwijk	Beverwijk	nl-nh-bev	nl,nl-nh,nl-haa,nl-nh-bev,nl-nh-bev
Blaricum	Blaricum	nl-nh-bla	nl,nl-nh,nl-ut,nl-aer,nl-nh-bla,nl-nh-bla
Bloemendaal	Bloemendaal	nl-nh-bmd	nl,nl-nh,nl-haa,nl-nh-bmd,nl-nh-bmd
Blokker	Hoorn	nl-nh-blk	nl,nl-nh,nl-hhw,nl-nh-hrn,nl-nh-blk
Boesingheliede	Haarlemmermeer	nl-nh-bue	nl,nl-nh,nl-haa,nl-ams,nl-nh-hmm,nl-nh-bue
Bovenkarspel	Stede Broec	nl-nh-bov	nl,nl-nh,nl-hhw,nl-nh-sbc,nl-nh-bov
Breezand	Hollands Kroon	nl-nh-brz	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-brz
Breukeleveen	Wijdemeren	nl-nh-wim	nl,nl-nh,nl-ut,nl-utc,nl-nh-wim
Broek in Waterland	Waterland	nl-nh-biw	nl,nl-nh,nl-ams,nl-nh-wtl,nl-nh-biw
Broek op Langedijk	Dijk en Waard	nl-nh-brl	nl,nl-nh,nl-hhw,nl-nh-hhw,nl-nh-brl
Buitenkaag	Haarlemmermeer	nl-nh-bka	nl,nl-nh,nl-zh,nl-lid,nl-nh-hmm,nl-nh-bka
Burgerbrug	Schagen	nl-nh-bgg	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-bgg
Burgerveen	Haarlemmermeer	nl-nh-hmm	nl,nl-nh,nl-zh,nl-ut,nl-lid,nl-haa,nl-nh-hmm
Bussum	Gooise Meren	nl-nh-bss	nl,nl-nh,nl-ut,nl-aer,nl-nh-bss,nl-nh-bss
Callantsoog	Schagen	nl-nh-cto	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-cto
Castricum	Castricum	nl-nh-cas	nl,nl-nh,nl-hhw,nl-haa,nl-nh-cas,nl-nh-cas
Cruquius	Haarlemmermeer	nl-nh-cru	nl,nl-nh,nl-zh,nl-haa,nl-nh-hmm,nl-nh-cru
De Cocksdorp	Texel	nl-nh-cdp	nl,nl-nh,nl-hrn,nl-nh-tex,nl-nh-cdp
De Goorn	Koggenland	nl-nh-oor	nl,nl-nh,nl-hhw,nl-nh-kol,nl-nh-oor
De Koog	Texel	nl-nh-tex	nl,nl-nh,nl-hhw,nl-hrn,nl-nh-tex
De Kwakel	Uithoorn	nl-nh-dkw	nl,nl-nh,nl-zh,nl-ut,nl-ams,nl-nh-uit,nl-nh-dkw
De Rijp	Alkmaar	nl-nh-drp	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-drp
De Waal	Texel	nl-nh-dea	nl,nl-nh,nl-hhw,nl-hrn,nl-nh-tex,nl-nh-dea
De Weere	Opmeer	nl-nh-zbq	nl,nl-nh,nl-hhw,nl-nh-zbq
de Woude	Castricum	nl-nh-cas	nl,nl-nh,nl-hhw,nl-nh-cas
Den Burg	Texel	nl-nh-dbg	nl,nl-nh,nl-hhw,nl-nh-tex,nl-nh-dbg
Den Helder	Den Helder	nl-nh-dhr	nl,nl-nh,nl-hhw,nl-nh-dhr,nl-nh-dhr
Den Hoorn	Texel	nl-nh-dhn	nl,nl-nh,nl-hhw,nl-nh-tex,nl-nh-dhn
Den Ilp	Landsmeer	nl-nh-lam	nl,nl-nh,nl-ams,nl-nh-lam
Den Oever	Hollands Kroon	nl-nh-hkn	nl,nl-nh,nl-hhw,nl-nh-hkn
Diemen	Diemen	nl-nh-dim	nl,nl-nh,nl-ut,nl-ams,nl-nh-dim,nl-nh-dim
Dirkshorn	Schagen	nl-nh-dik	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-dik
Driehuis NH	Velsen	nl-nh-vel	nl,nl-nh,nl-haa,nl-nh-vel
Driehuizen	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Duivendrecht	Ouder-Amstel	nl-nh-dvt	nl,nl-nh,nl-ut,nl-ams,nl-nh-odr,nl-nh-dvt
Edam	Edam-Volendam	nl-nh-edm	nl,nl-nh,nl-ams,nl-aer,nl-nh-evo,nl-nh-edm
Egmond aan den Hoef	Bergen (NH)	nl-nh-ead	nl,nl-nh,nl-hhw,nl-nh-bgn,nl-nh-ead
Egmond aan Zee	Bergen (NH)	nl-nh-eaz	nl,nl-nh,nl-hhw,nl-nh-bgn,nl-nh-eaz
Egmond-Binnen	Bergen (NH)	nl-nh-edb	nl,nl-nh,nl-hhw,nl-nh-bgn,nl-nh-edb
Enkhuizen	Enkhuizen	nl-nh-enk	nl,nl-nh,nl-hhw,nl-nh-enk,nl-nh-enk
Graft	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Groet	Bergen (NH)	nl-nh-bgn	nl,nl-nh,nl-hhw,nl-nh-bgn
Grootebroek	Stede Broec	nl-nh-gok	nl,nl-nh,nl-hhw,nl-nh-sbc,nl-nh-gok
Grootschermer	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Haarlem	Haarlem	nl-nh-haa	nl,nl-nh,nl-haa,nl-nh-haa,nl-nh-haa
Haarlemmerliede	Haarlemmermeer	nl-nh-hlr	nl,nl-nh,nl-haa,nl-nh-hmm,nl-nh-hlr
Halfweg	Haarlemmermeer	nl-nh-hfw	nl,nl-nh,nl-haa,nl-ams,nl-nh-hmm,nl-nh-hfw
Haringhuizen	Hollands Kroon	nl-nh-hkn	nl,nl-nh,nl-hhw,nl-nh-hkn
Hauwert	Medemblik	nl-nh-mdm	nl,nl-nh,nl-hhw,nl-nh-mdm
Heemskerk	Heemskerk	nl-nh-hke	nl,nl-nh,nl-haa,nl-nh-hke,nl-nh-hke
Heemstede	Heemstede	nl-nh-hms	nl,nl-nh,nl-zh,nl-haa,nl-nh-hms,nl-nh-hms
Heerhugowaard	Dijk en Waard	nl-nh-hhw	nl,nl-nh,nl-hhw,nl-nh-hhw,nl-nh-hhw
Heiloo	Heiloo	nl-nh-hlo	nl,nl-nh,nl-hhw,nl-nh-hlo,nl-nh-hlo
Hem	Drechterland	nl-nh-hem	nl,nl-nh,nl-hhw,nl-nh-hkp,nl-nh-hem
Hensbroek	Koggenland	nl-nh-kol	nl,nl-nh,nl-hhw,nl-nh-kol
Hilversum	Hilversum	nl-nh-hvs	nl,nl-nh,nl-ut,nl-utc,nl-aer,nl-ame,nl-nh-hvs,nl-nh-hvs
Hippolytushoef	Hollands Kroon	nl-nh-hph	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-hph
Hobrede	Edam-Volendam	nl-nh-evo	nl,nl-nh,nl-hhw,nl-nh-evo
Hoofddorp	Haarlemmermeer	nl-nh-hfd	nl,nl-nh,nl-zh,nl-haa,nl-nh-hmm,nl-nh-hfd
Hoogkarspel	Drechterland	nl-nh-hkp	nl,nl-nh,nl-hhw,nl-nh-hkp,nl-nh-hkp
Hoogwoud	Opmeer	nl-nh-hoo	nl,nl-nh,nl-hhw,nl-nh-zbq,nl-nh-hoo
Hoorn	Hoorn	nl-nh-hrn	nl,nl-nh,nl-hrn,nl-nh-hrn,nl-nh-hrn
Huisduinen	Den Helder	nl-nh-dhr	nl,nl-nh,nl-hhw,nl-nh-dhr
Huizen	Huizen	nl-nh-hui	nl,nl-nh,nl-ut,nl-fl,nl-aer,nl-nh-hui,nl-nh-hui
IJmuiden	Velsen	nl-nh-vel	nl,nl-nh,nl-haa,nl-nh-vel
Ilpendam	Waterland	nl-nh-ilp	nl,nl-nh,nl-ams,nl-nh-wtl,nl-nh-ilp
Jisp	Wormerland	nl-nh-jsp	nl,nl-nh,nl-ams,nl-nh-wom,nl-nh-jsp
Julianadorp	Den Helder	nl-nh-jld	nl,nl-nh,nl-hhw,nl-nh-dhr,nl-nh-jld
Katwoude	Waterland	nl-nh-kwo	nl,nl-nh,nl-ams,nl-aer,nl-nh-wtl,nl-nh-kwo
Koedijk	Dijk en Waard	nl-nh-kdj	nl,nl-nh,nl-hhw,nl-nh-hhw,nl-nh-kdj
Koedijk	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Kolhorn	Hollands Kroon	nl-nh-khr	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-khr
Koog aan de Zaan	Zaanstad	nl-nh-kgz	nl,nl-nh,nl-ams,nl-nh-zst,nl-nh-kgz
Kortenhoef	Wijdemeren	nl-nh-kth	nl,nl-nh,nl-ut,nl-aer,nl-utc,nl-nh-wim,nl-nh-kth
Kreileroord	Hollands Kroon	nl-nh-hkn	nl,nl-nh,nl-hhw,nl-nh-hkn
Krommenie	Zaanstad	nl-nh-krm	nl,nl-nh,nl-haa,nl-ams,nl-nh-zst,nl-nh-krm
Kudelstaart	Aalsmeer	nl-nh-kds	nl,nl-nh,nl-zh,nl-ut,nl-ams,nl-haa,nl-lid,nl-nh-aam,nl-nh-kds
Kwadijk	Edam-Volendam	nl-nh-kwj	nl,nl-nh,nl-ams,nl-hhw,nl-nh-evo,nl-nh-kwj
Lambertschaag	Medemblik	nl-nh-lbg	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-lbg
Landsmeer	Landsmeer	nl-nh-lam	nl,nl-nh,nl-ams,nl-nh-lam,nl-nh-lam
Laren	Laren	nl-nh-lar	nl,nl-nh,nl-ut,nl-aer,nl-nh-lar,nl-nh-lar
Leimuiderbrug	Haarlemmermeer	nl-nh-lru	nl,nl-nh,nl-zh,nl-lid,nl-nh-hmm,nl-nh-lru
Lijnden	Haarlemmermeer	nl-nh-lij	nl,nl-nh,nl-haa,nl-ams,nl-nh-hmm,nl-nh-lij
Limmen	Castricum	nl-nh-lmm	nl,nl-nh,nl-hhw,nl-nh-cas,nl-nh-lmm
Lisserbroek	Haarlemmermeer	nl-nh-lbk	nl,nl-nh,nl-zh,nl-lid,nl-nh-hmm,nl-nh-lbk
Loosdrecht	Wijdemeren	nl-nh-zaq	nl,nl-nh,nl-ut,nl-utc,nl-nh-wim,nl-nh-zaq
Lutjebroek	Stede Broec	nl-nh-ljb	nl,nl-nh,nl-hhw,nl-nh-sbc,nl-nh-ljb
Lutjewinkel	Hollands Kroon	nl-nh-lwk	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-lwk
Marken	Waterland	nl-nh-mkn	nl,nl-nh,nl-aer,nl-nh-wtl,nl-nh-mkn
Markenbinnen	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Medemblik	Medemblik	nl-nh-mdm	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-mdm
Middelie	Edam-Volendam	nl-nh-mve	nl,nl-nh,nl-hhw,nl-ams,nl-nh-evo,nl-nh-mve
Middenbeemster	Purmerend	nl-nh-mdi	nl,nl-nh,nl-hhw,nl-nh-pum,nl-nh-mdi
Middenmeer	Hollands Kroon	nl-nh-zbd	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-zbd
Midwoud	Medemblik	nl-nh-mdm	nl,nl-nh,nl-hhw,nl-nh-mdm
Monnickendam	Waterland	nl-nh-mnn	nl,nl-nh,nl-ams,nl-nh-wtl,nl-nh-mnn
Muiden	Gooise Meren	nl-nh-mud	nl,nl-nh,nl-ut,nl-aer,nl-ams,nl-nh-bss,nl-nh-mud
Muiderberg	Gooise Meren	nl-nh-mdg	nl,nl-nh,nl-fl,nl-ut,nl-aer,nl-nh-bss,nl-nh-mdg
Naarden	Gooise Meren	nl-nh-naa	nl,nl-nh,nl-ut,nl-fl,nl-aer,nl-nh-bss,nl-nh-naa
Nederhorst den Berg	Wijdemeren	nl-nh-ndb	nl,nl-nh,nl-ut,nl-ams,nl-aer,nl-nh-wim,nl-nh-ndb
Nibbixwoud	Medemblik	nl-nh-nxo	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-nxo
Nieuw-Vennep	Haarlemmermeer	nl-nh-nvp	nl,nl-nh,nl-zh,nl-haa,nl-nh-hmm,nl-nh-nvp
Nieuwe Niedorp	Hollands Kroon	nl-nh-hkn	nl,nl-nh,nl-hhw,nl-nh-hkn
Noord-Scharwoude	Dijk en Waard	nl-nh-nsw	nl,nl-nh,nl-hhw,nl-nh-hhw,nl-nh-nsw
Noordbeemster	Purmerend	nl-nh-nmt	nl,nl-nh,nl-hhw,nl-nh-pum,nl-nh-nmt
Noordeinde	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Obdam	Koggenland	nl-nh-obd	nl,nl-nh,nl-hhw,nl-nh-kol,nl-nh-obd
Oost-Graftdijk	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Oosterblokker	Drechterland	nl-nh-oer	nl,nl-nh,nl-hhw,nl-nh-hkp,nl-nh-oer
Oosterend	Texel	nl-nh-ood	nl,nl-nh,nl-hrn,nl-hhw,nl-nh-tex,nl-nh-ood
Oosterleek	Drechterland	nl-nh-hkp	nl,nl-nh,nl-hhw,nl-nh-hkp
Oosthuizen	Edam-Volendam	nl-nh-ohz	nl,nl-nh,nl-hhw,nl-nh-evo,nl-nh-ohz
Oostknollendam	Wormerland	nl-nh-wom	nl,nl-nh,nl-hhw,nl-ams,nl-haa,nl-nh-wom
Oostwoud	Medemblik	nl-nh-nho	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-nho
Oostzaan	Oostzaan	nl-nh-osz	nl,nl-nh,nl-ams,nl-nh-osz,nl-nh-osz
Opmeer	Opmeer	nl-nh-zbq	nl,nl-nh,nl-hhw,nl-nh-zbq,nl-nh-zbq
Opperdoes	Medemblik	nl-nh-opp	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-opp
Oterleek	Alkmaar	nl-nh-orl	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-orl
Oude Meer	Haarlemmermeer	nl-nh-oum	nl,nl-nh,nl-zh,nl-ut,nl-ams,nl-nh-hmm,nl-nh-oum
Oude Niedorp	Hollands Kroon	nl-nh-6ln	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-6ln
Oudendijk	Koggenland	nl-nh-odj	nl,nl-nh,nl-hhw,nl-nh-kol,nl-nh-odj
Ouderkerk aan de Amstel	Ouder-Amstel	nl-nh-odr	nl,nl-nh,nl-ut,nl-ams,nl-nh-odr,nl-nh-odr
Oudeschild	Texel	nl-nh-ohi	nl,nl-nh,nl-hhw,nl-nh-tex,nl-nh-ohi
Oudesluis	Schagen	nl-nh-osl	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-osl
Oudkarspel	Dijk en Waard	nl-nh-okp	nl,nl-nh,nl-hhw,nl-nh-hhw,nl-nh-okp
Oudkarspel	Schagen	nl-nh-sch	nl,nl-nh,nl-hhw,nl-nh-sch
Oudorp	Alkmaar	nl-nh-oud	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-oud
Overveen	Bloemendaal	nl-nh-ovv	nl,nl-nh,nl-haa,nl-nh-bmd,nl-nh-ovv
Petten	Schagen	nl-nh-ptt	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-ptt
Purmer	Waterland	nl-nh-wtl	nl,nl-nh,nl-ams,nl-nh-wtl
Purmer	Edam-Volendam	nl-nh-evo	nl,nl-nh,nl-ams,nl-nh-evo
Purmerend	Purmerend	nl-nh-pum	nl,nl-nh,nl-ams,nl-nh-pum,nl-nh-pum
Purmerland	Landsmeer	nl-nh-lam	nl,nl-nh,nl-ams,nl-nh-lam
Rijsenhout	Haarlemmermeer	nl-nh-rsh	nl,nl-nh,nl-zh,nl-ut,nl-haa,nl-nh-hmm,nl-nh-rsh
Rozenburg	Haarlemmermeer	nl-nh-rzg	nl,nl-nh,nl-zh,nl-ut,nl-haa,nl-ams,nl-nh-hmm,nl-nh-rzg
Santpoort-Noord	Velsen	nl-nh-stc	nl,nl-nh,nl-haa,nl-nh-vel,nl-nh-stc
Santpoort-Zuid	Velsen	nl-nh-vel	nl,nl-nh,nl-haa,nl-nh-vel
Schagen	Schagen	nl-nh-sch	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-sch
Schagerbrug	Schagen	nl-nh-sbu	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-sbu
Schardam	Edam-Volendam	nl-nh-evo	nl,nl-nh,nl-hhw,nl-nh-evo
Scharwoude	Koggenland	nl-nh-kol	nl,nl-nh,nl-hhw,nl-nh-kol
Schellinkhout	Drechterland	nl-nh-slh	nl,nl-nh,nl-hhw,nl-nh-hkp,nl-nh-slh
Schermerhorn	Alkmaar	nl-nh-sho	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-sho
Schiphol	Haarlemmermeer	nl-nh-spl	nl,nl-nh,nl-zh,nl-ut,nl-ams,nl-haa,nl-nh-hmm,nl-nh-spl
Schiphol-Rijk	Haarlemmermeer	nl-nh-srk	nl,nl-nh,nl-zh,nl-ut,nl-ams,nl-haa,nl-nh-hmm,nl-nh-srk
Schoorl	Bergen (NH)	nl-nh-srl	nl,nl-nh,nl-hhw,nl-nh-bgn,nl-nh-srl
Sijbekarspel	Medemblik	nl-nh-mdm	nl,nl-nh,nl-hhw,nl-nh-mdm
Sint Maarten	Schagen	nl-nh-smn	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-smn
Sint Maartensbrug	Schagen	nl-nh-zbe	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-zbe
Sint Maartensvlotbrug	Schagen	nl-nh-smv	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-smv
Sint Pancras	Dijk en Waard	nl-nh-anc	nl,nl-nh,nl-hhw,nl-nh-hhw,nl-nh-anc
Slootdorp	Hollands Kroon	nl-nh-sdp	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-sdp
Spaarndam	Haarlemmermeer	nl-nh-spd	nl,nl-nh,nl-haa,nl-nh-hmm,nl-nh-spd
Spaarndam gem. Haarlem	Haarlem	nl-nh-haa	nl,nl-nh,nl-haa,nl-nh-haa
Spanbroek	Opmeer	nl-nh-spb	nl,nl-nh,nl-hhw,nl-nh-zbq,nl-nh-spb
Spierdijk	Koggenland	nl-nh-sek	nl,nl-nh,nl-hhw,nl-nh-kol,nl-nh-sek
Spijkerboor	Wormerland	nl-nh-wom	nl,nl-nh,nl-hhw,nl-nh-wom
Starnmeer	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Stompetoren	Alkmaar	nl-nh-spt	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-spt
Tuitjenhorn	Schagen	nl-nh-tuh	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-tuh
Twisk	Medemblik	nl-nh-mdm	nl,nl-nh,nl-hhw,nl-nh-mdm
Uitdam	Waterland	nl-nh-wtl	nl,nl-nh,nl-aer,nl-ams,nl-nh-wtl
Uitgeest	Uitgeest	nl-nh-utg	nl,nl-nh,nl-haa,nl-hhw,nl-nh-utg,nl-nh-utg
Uithoorn	Uithoorn	nl-nh-uit	nl,nl-nh,nl-ut,nl-zh,nl-ams,nl-nh-uit,nl-nh-uit
Ursem	Alkmaar	nl-nh-urs	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-urs
Ursem	Koggenland	nl-nh-kol	nl,nl-nh,nl-hhw,nl-nh-kol
Velsen-Noord	Velsen	nl-nh-vsn	nl,nl-nh,nl-haa,nl-nh-vel,nl-nh-vsn
Velsen-Zuid	Velsen	nl-nh-vel	nl,nl-nh,nl-haa,nl-nh-vel
Velserbroek	Velsen	nl-nh-vbk	nl,nl-nh,nl-haa,nl-nh-vel,nl-nh-vbk
Venhuizen	Drechterland	nl-nh-vnh	nl,nl-nh,nl-hhw,nl-nh-hkp,nl-nh-vnh
Vijfhuizen	Haarlemmermeer	nl-nh-vij	nl,nl-nh,nl-zh,nl-haa,nl-nh-hmm,nl-nh-vij
Vogelenzang	Bloemendaal	nl-nh-vgg	nl,nl-nh,nl-zh,nl-haa,nl-nh-bmd,nl-nh-vgg
Volendam	Edam-Volendam	nl-nh-vod	nl,nl-nh,nl-aer,nl-ams,nl-nh-evo,nl-nh-vod
Waarland	Schagen	nl-nh-wrl	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-wrl
Warder	Edam-Volendam	nl-nh-wrd	nl,nl-nh,nl-hhw,nl-nh-evo,nl-nh-wrd
Warmenhuizen	Schagen	nl-nh-wmh	nl,nl-nh,nl-hhw,nl-nh-sch,nl-nh-wmh
Watergang	Waterland	nl-nh-wtg	nl,nl-nh,nl-ams,nl-nh-wtl,nl-nh-wtg
Weesp	Amsterdam	nl-nh-wsp	nl,nl-nh,nl-ut,nl-ams,nl-aer,nl-nh-ams,nl-nh-wsp
Wervershoof	Medemblik	nl-nh-weh	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-weh
West-Graftdijk	Alkmaar	nl-nh-wgd	nl,nl-nh,nl-hhw,nl-nh-alk,nl-nh-wgd
Westbeemster	Purmerend	nl-nh-wbs	nl,nl-nh,nl-hhw,nl-nh-pum,nl-nh-wbs
Westerland	Hollands Kroon	nl-nh-hkn	nl,nl-nh,nl-hhw,nl-nh-hkn
Westknollendam	Zaanstad	nl-nh-zst	nl,nl-nh,nl-hhw,nl-haa,nl-ams,nl-nh-zst
Westwoud	Drechterland	nl-nh-wtu	nl,nl-nh,nl-hhw,nl-nh-hkp,nl-nh-wtu
Westzaan	Zaanstad	nl-nh-wtz	nl,nl-nh,nl-haa,nl-ams,nl-nh-zst,nl-nh-wtz
Weteringbrug	Haarlemmermeer	nl-nh-hmm	nl,nl-nh,nl-zh,nl-lid,nl-nh-hmm
Wieringerwaard	Hollands Kroon	nl-nh-wwe	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-wwe
Wieringerwerf	Hollands Kroon	nl-nh-wiw	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-wiw
Wijdenes	Drechterland	nl-nh-wds	nl,nl-nh,nl-hhw,nl-nh-hkp,nl-nh-wds
Wijdewormer	Wormerland	nl-nh-wwo	nl,nl-nh,nl-ams,nl-nh-wom,nl-nh-wwo
Wijk aan Zee	Beverwijk	nl-nh-bev	nl,nl-nh,nl-haa,nl-nh-bev
Winkel	Hollands Kroon	nl-nh-wnk	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-wnk
Wognum	Medemblik	nl-nh-wgn	nl,nl-nh,nl-hhw,nl-nh-mdm,nl-nh-wgn
Wormer	Wormerland	nl-nh-wmo	nl,nl-nh,nl-ams,nl-nh-wom,nl-nh-wmo
Wormerveer	Zaanstad	nl-nh-wrv	nl,nl-nh,nl-ams,nl-haa,nl-nh-zst,nl-nh-wrv
Zaandam	Zaanstad	nl-nh-zaa	nl,nl-nh,nl-ams,nl-nh-zst,nl-nh-zaa
Zaandijk	Zaanstad	nl-nh-zad	nl,nl-nh,nl-ams,nl-nh-zst,nl-nh-zad
Zandvoort	Zandvoort	nl-nh-zdv	nl,nl-nh,nl-zh,nl-haa,nl-nh-zdv,nl-nh-zdv
Zijdewind	Hollands Kroon	nl-nh-zdw	nl,nl-nh,nl-hhw,nl-nh-hkn,nl-nh-zdw
Zuid-Scharwoude	Dijk en Waard	nl-nh-zsc	nl,nl-nh,nl-hhw,nl-nh-hhw,nl-nh-zsc
Zuidermeer	Koggenland	nl-nh-kol	nl,nl-nh,nl-hhw,nl-nh-kol
Zuiderwoude	Waterland	nl-nh-wtl	nl,nl-nh,nl-ams,nl-nh-wtl
Zuidoostbeemster	Purmerend	nl-nh-zob	nl,nl-nh,nl-ams,nl-nh-pum,nl-nh-zob
Zuidschermer	Alkmaar	nl-nh-alk	nl,nl-nh,nl-hhw,nl-nh-alk
Zwaag	Hoorn	nl-nh-zag	nl,nl-nh,nl-hhw,nl-nh-hrn,nl-nh-zag
Zwaagdijk-Oost	Medemblik	nl-nh-mdm	nl,nl-nh,nl-hhw,nl-nh-mdm
Zwaagdijk-West	Medemblik	nl-nh-mdm	nl,nl-nh,nl-hhw,nl-nh-mdm
Zwaanshoek	Haarlemmermeer	nl-nh-zho	nl,nl-nh,nl-zh,nl-haa,nl-nh-hmm,nl-nh-zho
Zwanenburg	Haarlemmermeer	nl-nh-zwa	nl,nl-nh,nl-haa,nl-ams,nl-nh-hmm,nl-nh-zwa
's-Gravendeel	Hoeksche Waard	nl-zh-gra	nl,nl-zh,nl-nb,nl-dor,nl-zh-obl,nl-zh-gra
's-Gravenzande	Westland	nl-zh-grz	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-grz
Aarlanderveen	Alphen aan den Rijn	nl-zh-adv	nl,nl-zh,nl-ut,nl-lid,nl-zh-apn,nl-zh-adv
Abbenbroek	Nissewaard	nl-zh-abk	nl,nl-zh,nl-rtm,nl-zh-nbn,nl-zh-abk
Achthuizen	Goeree-Overflakkee	nl-zh-ahz	nl,nl-zh,nl-nb,nl-roo,nl-bzm,nl-zh-gof,nl-zh-ahz
Alblasserdam	Alblasserdam	nl-zh-abl	nl,nl-zh,nl-dor,nl-zh-abl,nl-zh-abl
Alphen aan den Rijn	Alphen aan den Rijn	nl-zh-apn	nl,nl-zh,nl-nh,nl-lid,nl-zh-apn,nl-zh-apn
Ammerstol	Krimpenerwaard	nl-zh-amm	nl,nl-zh,nl-ut,nl-dor,nl-zh-shh,nl-zh-amm
Arkel	Molenlanden	nl-zh-ark	nl,nl-zh,nl-ge,nl-ut,nl-dor,nl-zh-gie,nl-zh-ark
Barendrecht	Barendrecht	nl-zh-brr	nl,nl-zh,nl-rtm,nl-dor,nl-zh-brr,nl-zh-brr
Benthuizen	Alphen aan den Rijn	nl-zh-bhz	nl,nl-zh,nl-lid,nl-hag,nl-zh-apn,nl-zh-bhz
Bergambacht	Krimpenerwaard	nl-zh-bgb	nl,nl-zh,nl-ut,nl-dor,nl-zh-shh,nl-zh-bgb
Bergschenhoek	Lansingerland	nl-zh-bek	nl,nl-zh,nl-rtm,nl-hag,nl-zh-lsg,nl-zh-bek
Berkel en Rodenrijs	Lansingerland	nl-zh-ber	nl,nl-zh,nl-rtm,nl-hag,nl-zh-lsg,nl-zh-ber
Berkenwoude	Krimpenerwaard	nl-zh-shh	nl,nl-zh,nl-dor,nl-rtm,nl-zh-shh
Bleiswijk	Lansingerland	nl-zh-blw	nl,nl-zh,nl-rtm,nl-hag,nl-zh-lsg,nl-zh-blw
Bleskensgraaf ca	Molenlanden	nl-zh-gie	nl,nl-zh,nl-dor,nl-zh-gie
Bodegraven	Bodegraven-Reeuwijk	nl-zh-bog	nl,nl-zh,nl-ut,nl-lid,nl-zh-brw,nl-zh-bog
Boskoop	Alphen aan den Rijn	nl-zh-bsk	nl,nl-zh,nl-lid,nl-zh-apn,nl-zh-bsk
Botlek Rotterdam	Rotterdam	nl-zh-rtm	nl,nl-zh,nl-rtm,nl-zh-rtm
Brandwijk	Molenlanden	nl-zh-gie	nl,nl-zh,nl-dor,nl-zh-gie
Brielle	Voorne aan Zee	nl-zh-bri	nl,nl-zh,nl-hag,nl-rtm,nl-zh-hsl,nl-zh-bri
Capelle aan den IJssel	Capelle aan den IJssel	nl-zh-cpi	nl,nl-zh,nl-rtm,nl-zh-cpi,nl-zh-cpi
Dalem	Gorinchem	nl-zh-gor	nl,nl-zh,nl-nb,nl-ge,nl-dor,nl-htb,nl-zh-gor
De Lier	Westland	nl-zh-dlr	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-dlr
De Zilk	Noordwijk	nl-zh-dzk	nl,nl-zh,nl-nh,nl-haa,nl-zh-ndw,nl-zh-dzk
Delfgauw	Pijnacker-Nootdorp	nl-zh-dgw	nl,nl-zh,nl-hag,nl-rtm,nl-zh-pin,nl-zh-dgw
Delft	Delft	nl-zh-dft	nl,nl-zh,nl-hag,nl-rtm,nl-zh-dft,nl-zh-dft
Den Bommel	Goeree-Overflakkee	nl-zh-dbm	nl,nl-zh,nl-roo,nl-bzm,nl-zh-gof,nl-zh-dbm
Den Haag	's-Gravenhage	nl-zh-hag	nl,nl-zh,nl-hag,nl-zh-hag,nl-zh-hag
Den Hoorn	Midden-Delfland	nl-zh-dhn	nl,nl-zh,nl-hag,nl-rtm,nl-zh-mdf,nl-zh-dhn
Dirksland	Goeree-Overflakkee	nl-zh-drk	nl,nl-zh,nl-ze,nl-bzm,nl-rtm,nl-zh-gof,nl-zh-drk
Dordrecht	Dordrecht	nl-zh-dor	nl,nl-zh,nl-dor,nl-zh-dor,nl-zh-dor
Driebruggen	Bodegraven-Reeuwijk	nl-zh-dbu	nl,nl-zh,nl-ut,nl-utc,nl-zh-brw,nl-zh-dbu
Europoort Rotterdam	Rotterdam	nl-zh-rtm	nl,nl-zh,nl-hag,nl-zh-rtm
Geervliet	Nissewaard	nl-zh-grv	nl,nl-zh,nl-rtm,nl-zh-nbn,nl-zh-grv
Gelderswoude	Zoeterwoude	nl-zh-zou	nl,nl-zh,nl-lid,nl-hag,nl-zh-zou
Giessenburg	Molenlanden	nl-zh-gie	nl,nl-zh,nl-nb,nl-ge,nl-dor,nl-zh-gie
Goedereede	Goeree-Overflakkee	nl-zh-gdr	nl,nl-zh,nl-rtm,nl-hag,nl-zh-gof,nl-zh-gdr
Gorinchem	Gorinchem	nl-zh-gor	nl,nl-zh,nl-nb,nl-ge,nl-dor,nl-zh-gor,nl-zh-gor
Gouda	Gouda	nl-zh-gou	nl,nl-zh,nl-ut,nl-rtm,nl-zh-gou,nl-zh-gou
Gouderak	Krimpenerwaard	nl-zh-gdk	nl,nl-zh,nl-ut,nl-rtm,nl-zh-shh,nl-zh-gdk
Goudriaan	Molenlanden	nl-zh-gun	nl,nl-zh,nl-ut,nl-ge,nl-dor,nl-zh-gie,nl-zh-gun
Goudswaard	Hoeksche Waard	nl-zh-gow	nl,nl-zh,nl-rtm,nl-zh-obl,nl-zh-gow
Groot-Ammers	Molenlanden	nl-zh-gro	nl,nl-zh,nl-ut,nl-dor,nl-zh-gie,nl-zh-gro
Haastrecht	Krimpenerwaard	nl-zh-hch	nl,nl-zh,nl-ut,nl-dor,nl-rtm,nl-zh-shh,nl-zh-hch
Hardinxveld-Giessendam	Hardinxveld-Giessendam	nl-zh-hxg	nl,nl-zh,nl-nb,nl-dor,nl-zh-hxg,nl-zh-hxg
Hazerswoude-Dorp	Alphen aan den Rijn	nl-zh-hwd	nl,nl-zh,nl-lid,nl-zh-apn,nl-zh-hwd
Hazerswoude-Rijndijk	Alphen aan den Rijn	nl-zh-apn	nl,nl-zh,nl-lid,nl-zh-apn
Heenvliet	Nissewaard	nl-zh-nbn	nl,nl-zh,nl-rtm,nl-zh-nbn
Heerjansdam	Zwijndrecht	nl-zh-hkf	nl,nl-zh,nl-dor,nl-rtm,nl-zh-zwi,nl-zh-hkf
Heinenoord	Hoeksche Waard	nl-zh-hod	nl,nl-zh,nl-rtm,nl-dor,nl-zh-obl,nl-zh-hod
Hekelingen	Nissewaard	nl-zh-hek	nl,nl-zh,nl-rtm,nl-zh-nbn,nl-zh-hek
Hellevoetsluis	Voorne aan Zee	nl-zh-hsl	nl,nl-zh,nl-rtm,nl-zh-hsl,nl-zh-hsl
Hendrik-Ido-Ambacht	Hendrik-Ido-Ambacht	nl-zh-hia	nl,nl-zh,nl-dor,nl-zh-hia,nl-zh-hia
Herkingen	Goeree-Overflakkee	nl-zh-hki	nl,nl-zh,nl-ze,nl-bzm,nl-zh-gof,nl-zh-hki
Hillegom	Hillegom	nl-zh-hil	nl,nl-zh,nl-nh,nl-haa,nl-zh-hil,nl-zh-hil
Hoek van Holland	Rotterdam	nl-zh-hvh	nl,nl-zh,nl-hag,nl-zh-rtm,nl-zh-hvh
Honselersdijk	Westland	nl-zh-hns	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-hns
Hoogblokland	Molenlanden	nl-zh-gie	nl,nl-zh,nl-ge,nl-ut,nl-dor,nl-zh-gie
Hoogmade	Kaag en Braassem	nl-zh-hgm	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa,nl-zh-hgm
Hoogvliet Rotterdam	Rotterdam	nl-zh-rtm	nl,nl-zh,nl-rtm,nl-zh-rtm
Hoornaar	Molenlanden	nl-zh-hna	nl,nl-zh,nl-ge,nl-ut,nl-dor,nl-zh-gie,nl-zh-hna
Kaag	Kaag en Braassem	nl-zh-kag	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa,nl-zh-kag
Katwijk	Katwijk	nl-zh-kwk	nl,nl-zh,nl-nh,nl-lid,nl-zh-kwk,nl-zh-kwk
Kinderdijk	Molenlanden	nl-zh-kij	nl,nl-zh,nl-dor,nl-rtm,nl-zh-gie,nl-zh-kij
Klaaswaal	Hoeksche Waard	nl-zh-klw	nl,nl-zh,nl-nb,nl-dor,nl-rtm,nl-zh-obl,nl-zh-klw
Koudekerk aan den Rijn	Alphen aan den Rijn	nl-zh-kor	nl,nl-zh,nl-nh,nl-lid,nl-zh-apn,nl-zh-kor
Krimpen aan de Lek	Krimpenerwaard	nl-zh-krp	nl,nl-zh,nl-dor,nl-rtm,nl-zh-shh,nl-zh-krp
Krimpen aan den IJssel	Krimpen aan den IJssel	nl-zh-kai	nl,nl-zh,nl-rtm,nl-dor,nl-zh-kai,nl-zh-kai
Kwintsheul	Westland	nl-zh-kws	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-kws
Langerak	Molenlanden	nl-zh-lag	nl,nl-zh,nl-ut,nl-dor,nl-zh-gie,nl-zh-lag
Leiden	Leiden	nl-zh-lid	nl,nl-zh,nl-nh,nl-lid,nl-zh-lid,nl-zh-lid
Leiderdorp	Leiderdorp	nl-zh-ldd	nl,nl-zh,nl-nh,nl-lid,nl-zh-ldd,nl-zh-ldd
Leidschendam	Leidschendam-Voorburg	nl-zh-lds	nl,nl-zh,nl-hag,nl-lid,nl-zh-lsv,nl-zh-lds
Leimuiden	Kaag en Braassem	nl-zh-lmu	nl,nl-zh,nl-nh,nl-ut,nl-lid,nl-zh-kaa,nl-zh-lmu
Lekkerkerk	Krimpenerwaard	nl-zh-lek	nl,nl-zh,nl-dor,nl-zh-shh,nl-zh-lek
Lisse	Lisse	nl-zh-qdg	nl,nl-zh,nl-nh,nl-lid,nl-zh-qdg,nl-zh-qdg
Maasdam	Hoeksche Waard	nl-zh-msd	nl,nl-zh,nl-dor,nl-zh-obl,nl-zh-msd
Maasdijk	Westland	nl-zh-mdk	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-mdk
Maasland	Midden-Delfland	nl-zh-mal	nl,nl-zh,nl-hag,nl-rtm,nl-zh-mdf,nl-zh-mal
Maassluis	Maassluis	nl-zh-msl	nl,nl-zh,nl-rtm,nl-hag,nl-zh-msl,nl-zh-msl
Maasvlakte Rotterdam	Rotterdam	nl-zh-rtm	nl,nl-zh,nl-hag,nl-zh-rtm
Melissant	Goeree-Overflakkee	nl-zh-msa	nl,nl-zh,nl-ze,nl-rtm,nl-bzm,nl-zh-gof,nl-zh-msa
Middelharnis	Goeree-Overflakkee	nl-zh-mih	nl,nl-zh,nl-rtm,nl-bzm,nl-zh-gof,nl-zh-mih
Mijnsheerenland	Hoeksche Waard	nl-zh-mnh	nl,nl-zh,nl-dor,nl-rtm,nl-zh-obl,nl-zh-mnh
Moerkapelle	Zuidplas	nl-zh-mkp	nl,nl-zh,nl-lid,nl-rtm,nl-hag,nl-zh-zdp,nl-zh-mkp
Molenaarsgraaf	Molenlanden	nl-zh-mog	nl,nl-zh,nl-nb,nl-dor,nl-zh-gie,nl-zh-mog
Monster	Westland	nl-zh-mon	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-mon
Mookhoek	Hoeksche Waard	nl-zh-mhk	nl,nl-zh,nl-nb,nl-dor,nl-zh-obl,nl-zh-mhk
Moordrecht	Zuidplas	nl-zh-moo	nl,nl-zh,nl-ut,nl-rtm,nl-zh-zdp,nl-zh-moo
Naaldwijk	Westland	nl-zh-naw	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-naw
Nieuw-Beijerland	Hoeksche Waard	nl-zh-obl	nl,nl-zh,nl-rtm,nl-zh-obl
Nieuw-Lekkerland	Molenlanden	nl-zh-nlk	nl,nl-zh,nl-dor,nl-zh-gie,nl-zh-nlk
Nieuwe Wetering	Kaag en Braassem	nl-zh-kaa	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa
Nieuwe-Tonge	Goeree-Overflakkee	nl-zh-nwt	nl,nl-zh,nl-ze,nl-bzm,nl-zh-gof,nl-zh-nwt
Nieuwerbrug aan den Rijn	Bodegraven-Reeuwijk	nl-zh-brw	nl,nl-zh,nl-ut,nl-utc,nl-zh-brw
Nieuwerkerk aan den IJssel	Zuidplas	nl-zh-nie	nl,nl-zh,nl-rtm,nl-zh-zdp,nl-zh-nie
Nieuwkoop	Nieuwkoop	nl-zh-nwk	nl,nl-zh,nl-ut,nl-nh,nl-lid,nl-zh-nwk,nl-zh-nwk
Nieuwpoort	Molenlanden	nl-zh-nwp	nl,nl-zh,nl-ut,nl-dor,nl-zh-gie,nl-zh-nwp
Nieuwveen	Nieuwkoop	nl-zh-nwv	nl,nl-zh,nl-ut,nl-nh,nl-lid,nl-zh-nwk,nl-zh-nwv
Noordeloos	Molenlanden	nl-zh-nz8	nl,nl-zh,nl-ut,nl-ge,nl-dor,nl-zh-gie,nl-zh-nz8
Noorden	Nieuwkoop	nl-zh-ndn	nl,nl-zh,nl-ut,nl-nh,nl-utc,nl-lid,nl-ams,nl-zh-nwk,nl-zh-ndn
Noordwijk	Noordwijk	nl-zh-ndw	nl,nl-zh,nl-nh,nl-lid,nl-zh-ndw,nl-zh-ndw
Noordwijkerhout	Noordwijk	nl-zh-noj	nl,nl-zh,nl-nh,nl-lid,nl-zh-ndw,nl-zh-noj
Nootdorp	Pijnacker-Nootdorp	nl-zh-ndp	nl,nl-zh,nl-hag,nl-zh-pin,nl-zh-ndp
Numansdorp	Hoeksche Waard	nl-zh-nud	nl,nl-zh,nl-nb,nl-dor,nl-zh-obl,nl-zh-nud
Oegstgeest	Oegstgeest	nl-zh-oge	nl,nl-zh,nl-nh,nl-lid,nl-zh-oge,nl-zh-oge
Ooltgensplaat	Goeree-Overflakkee	nl-zh-ogp	nl,nl-zh,nl-nb,nl-roo,nl-zh-gof,nl-zh-ogp
Oostvoorne	Voorne aan Zee	nl-zh-ovn	nl,nl-zh,nl-hag,nl-zh-hsl,nl-zh-ovn
Ottoland	Molenlanden	nl-zh-gie	nl,nl-zh,nl-nb,nl-ut,nl-dor,nl-zh-gie
Oud Ade	Kaag en Braassem	nl-zh-oua	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa,nl-zh-oua
Oud-Alblas	Molenlanden	nl-zh-a2z	nl,nl-zh,nl-dor,nl-zh-gie,nl-zh-a2z
Oud-Beijerland	Hoeksche Waard	nl-zh-obl	nl,nl-zh,nl-rtm,nl-zh-obl,nl-zh-obl
Ouddorp	Goeree-Overflakkee	nl-zh-odu	nl,nl-zh,nl-ze,nl-rtm,nl-hag,nl-mdl,nl-bzm,nl-zh-gof,nl-zh-odu
Oude Wetering	Kaag en Braassem	nl-zh-owg	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa,nl-zh-owg
Oude-Tonge	Goeree-Overflakkee	nl-zh-odt	nl,nl-zh,nl-ze,nl-nb,nl-bzm,nl-roo,nl-zh-gof,nl-zh-odt
Oudenhoorn	Voorne aan Zee	nl-zh-odh	nl,nl-zh,nl-rtm,nl-zh-hsl,nl-zh-odh
Ouderkerk aan den IJssel	Krimpenerwaard	nl-zh-oai	nl,nl-zh,nl-rtm,nl-dor,nl-zh-shh,nl-zh-oai
Papendrecht	Papendrecht	nl-zh-pap	nl,nl-zh,nl-dor,nl-zh-pap,nl-zh-pap
Pernis Rotterdam	Rotterdam	nl-zh-rtm	nl,nl-zh,nl-rtm,nl-zh-rtm
Piershil	Hoeksche Waard	nl-zh-psi	nl,nl-zh,nl-rtm,nl-zh-obl,nl-zh-psi
Pijnacker	Pijnacker-Nootdorp	nl-zh-pij	nl,nl-zh,nl-hag,nl-rtm,nl-zh-pin,nl-zh-pij
Poeldijk	Westland	nl-zh-pdk	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-pdk
Poortugaal	Albrandswaard	nl-zh-ptg	nl,nl-zh,nl-rtm,nl-zh-awd,nl-zh-ptg
Puttershoek	Hoeksche Waard	nl-zh-ptk	nl,nl-zh,nl-dor,nl-zh-obl,nl-zh-ptk
Reeuwijk	Bodegraven-Reeuwijk	nl-zh-ruw	nl,nl-zh,nl-ut,nl-lid,nl-rtm,nl-zh-brw,nl-zh-ruw
Rhoon	Albrandswaard	nl-zh-rho	nl,nl-zh,nl-rtm,nl-zh-awd,nl-zh-rho
Ridderkerk	Ridderkerk	nl-zh-rid	nl,nl-zh,nl-dor,nl-rtm,nl-zh-rid,nl-zh-rid
Rijnsaterwoude	Kaag en Braassem	nl-zh-rsw	nl,nl-zh,nl-nh,nl-ut,nl-lid,nl-zh-kaa,nl-zh-rsw
Rijnsburg	Katwijk	nl-zh-rbg	nl,nl-zh,nl-nh,nl-lid,nl-zh-kwk,nl-zh-rbg
Rijpwetering	Kaag en Braassem	nl-zh-rwi	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa,nl-zh-rwi
Rijswijk	Rijswijk	nl-zh-rys	nl,nl-zh,nl-hag,nl-zh-rys,nl-zh-rys
Rockanje	Voorne aan Zee	nl-zh-roc	nl,nl-zh,nl-hag,nl-rtm,nl-zh-hsl,nl-zh-roc
Roelofarendsveen	Kaag en Braassem	nl-zh-rav	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa,nl-zh-rav
Rotterdam	Rotterdam	nl-zh-rtm	nl,nl-zh,nl-rtm,nl-zh-rtm,nl-zh-rtm
Rotterdam-Albrandswaard	Albrandswaard	nl-zh-awd	nl,nl-zh,nl-rtm,nl-zh-awd
Rozenburg	Rotterdam	nl-zh-roz	nl,nl-zh,nl-rtm,nl-hag,nl-zh-rtm,nl-zh-roz
Sassenheim	Teylingen	nl-zh-sas	nl,nl-zh,nl-nh,nl-lid,nl-zh-tey,nl-zh-sas
Schelluinen	Molenlanden	nl-zh-sln	nl,nl-zh,nl-nb,nl-ge,nl-dor,nl-zh-gie,nl-zh-sln
Schiedam	Schiedam	nl-zh-sci	nl,nl-zh,nl-rtm,nl-zh-sci,nl-zh-sci
Schipluiden	Midden-Delfland	nl-zh-scp	nl,nl-zh,nl-hag,nl-rtm,nl-zh-mdf,nl-zh-scp
Schoonhoven	Krimpenerwaard	nl-zh-shh	nl,nl-zh,nl-ut,nl-dor,nl-zh-shh,nl-zh-shh
Simonshaven	Nissewaard	nl-zh-nbn	nl,nl-zh,nl-rtm,nl-zh-nbn
Sliedrecht	Sliedrecht	nl-zh-sld	nl,nl-zh,nl-nb,nl-dor,nl-zh-sld,nl-zh-sld
Sommelsdijk	Goeree-Overflakkee	nl-zh-sij	nl,nl-zh,nl-rtm,nl-bzm,nl-zh-gof,nl-zh-sij
Spijkenisse	Nissewaard	nl-zh-spi	nl,nl-zh,nl-rtm,nl-zh-nbn,nl-zh-spi
Stad aan 't Haringvliet	Goeree-Overflakkee	nl-zh-sat	nl,nl-zh,nl-rtm,nl-roo,nl-bzm,nl-zh-gof,nl-zh-sat
Stellendam	Goeree-Overflakkee	nl-zh-std	nl,nl-zh,nl-rtm,nl-hag,nl-zh-gof,nl-zh-std
Stolwijk	Krimpenerwaard	nl-zh-swj	nl,nl-zh,nl-ut,nl-dor,nl-zh-shh,nl-zh-swj
Streefkerk	Molenlanden	nl-zh-sre	nl,nl-zh,nl-dor,nl-zh-gie,nl-zh-sre
Strijen	Hoeksche Waard	nl-zh-trj	nl,nl-zh,nl-nb,nl-dor,nl-zh-obl,nl-zh-trj
Strijensas	Hoeksche Waard	nl-zh-obl	nl,nl-zh,nl-nb,nl-dor,nl-zh-obl
Ter Aar	Nieuwkoop	nl-zh-tea	nl,nl-zh,nl-nh,nl-ut,nl-lid,nl-zh-nwk,nl-zh-tea
Ter Heijde	Westland	nl-zh-thd	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-thd
Tinte	Voorne aan Zee	nl-zh-hsl	nl,nl-zh,nl-hag,nl-rtm,nl-zh-hsl
Valkenburg	Katwijk	nl-zh-vlk	nl,nl-zh,nl-nh,nl-lid,nl-zh-kwk,nl-zh-vlk
Vierpolders	Voorne aan Zee	nl-zh-vpd	nl,nl-zh,nl-rtm,nl-hag,nl-zh-hsl,nl-zh-vpd
Vlaardingen	Vlaardingen	nl-zh-vla	nl,nl-zh,nl-rtm,nl-zh-vla,nl-zh-vla
Vlist	Krimpenerwaard	nl-zh-shh	nl,nl-zh,nl-ut,nl-dor,nl-zh-shh
Vondelingenplaat Rotterdam	Rotterdam	nl-zh-rtm	nl,nl-zh,nl-rtm,nl-zh-rtm
Voorburg	Leidschendam-Voorburg	nl-zh-vob	nl,nl-zh,nl-hag,nl-lid,nl-zh-lsv,nl-zh-vob
Voorhout	Teylingen	nl-zh-voh	nl,nl-zh,nl-nh,nl-lid,nl-zh-tey,nl-zh-voh
Voorschoten	Voorschoten	nl-zh-vos	nl,nl-zh,nl-lid,nl-hag,nl-zh-vos,nl-zh-vos
Vrouwenakker	Nieuwkoop	nl-zh-vra	nl,nl-zh,nl-nh,nl-ut,nl-ams,nl-zh-nwk,nl-zh-vra
Waal	Molenlanden	nl-zh-gie	nl,nl-zh,nl-ut,nl-dor,nl-utc,nl-zh-gie
Waarder	Bodegraven-Reeuwijk	nl-zh-wdr	nl,nl-zh,nl-ut,nl-utc,nl-zh-brw,nl-zh-wdr
Waddinxveen	Waddinxveen	nl-zh-wad	nl,nl-zh,nl-lid,nl-rtm,nl-zh-wad,nl-zh-wad
Warmond	Teylingen	nl-zh-wrm	nl,nl-zh,nl-nh,nl-lid,nl-zh-tey,nl-zh-wrm
Wassenaar	Wassenaar	nl-zh-wss	nl,nl-zh,nl-lid,nl-hag,nl-zh-wss,nl-zh-wss
Wateringen	Westland	nl-zh-wat	nl,nl-zh,nl-hag,nl-zh-wet,nl-zh-wat
Westmaas	Hoeksche Waard	nl-zh-wem	nl,nl-zh,nl-dor,nl-zh-obl,nl-zh-wem
Wijngaarden	Molenlanden	nl-zh-gie	nl,nl-zh,nl-nb,nl-dor,nl-zh-gie
Woerdense Verlaat	Nieuwkoop	nl-zh-nwk	nl,nl-zh,nl-ut,nl-nh,nl-utc,nl-zh-nwk
Woubrugge	Kaag en Braassem	nl-zh-wbg	nl,nl-zh,nl-nh,nl-lid,nl-zh-kaa,nl-zh-wbg
Zevenhoven	Nieuwkoop	nl-zh-zhv	nl,nl-zh,nl-ut,nl-nh,nl-lid,nl-zh-nwk,nl-zh-zhv
Zevenhuizen	Zuidplas	nl-zh-zhz	nl,nl-zh,nl-rtm,nl-zh-zdp,nl-zh-zhz
Zoetermeer	Zoetermeer	nl-zh-ztm	nl,nl-zh,nl-hag,nl-lid,nl-zh-ztm,nl-zh-ztm
Zoeterwoude	Zoeterwoude	nl-zh-zou	nl,nl-zh,nl-lid,nl-hag,nl-zh-zou,nl-zh-zou
Zuid-Beijerland	Hoeksche Waard	nl-zh-zbj	nl,nl-zh,nl-nb,nl-rtm,nl-dor,nl-zh-obl,nl-zh-zbj
Zuidland	Nissewaard	nl-zh-zul	nl,nl-zh,nl-rtm,nl-zh-nbn,nl-zh-zul
Zwammerdam	Alphen aan den Rijn	nl-zh-zmm	nl,nl-zh,nl-ut,nl-lid,nl-zh-apn,nl-zh-zmm
Zwartewaal	Voorne aan Zee	nl-zh-zww	nl,nl-zh,nl-rtm,nl-zh-hsl,nl-zh-zww
Zwijndrecht	Zwijndrecht	nl-zh-zwi	nl,nl-zh,nl-dor,nl-zh-zwi,nl-zh-zwi
's-Gravenpolder	Borsele	nl-ze-sgp	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-sgp
's-Heer Abtskerke	Borsele	nl-ze-bor	nl,nl-ze,nl-mdl,nl-ze-bor
's-Heer Arendskerke	Goes	nl-ze-goe	nl,nl-ze,nl-mdl,nl-ze-goe
's-Heer Hendrikskinderen	Goes	nl-ze-goe	nl,nl-ze,nl-mdl,nl-ze-goe
's-Heerenhoek	Borsele	nl-ze-she	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-she
Aagtekerke	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver
Aardenburg	Sluis	nl-ze-aar	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-aar
Arnemuiden	Middelburg	nl-ze-arm	nl,nl-ze,nl-mdl,nl-ze-mdl,nl-ze-arm
Axel	Terneuzen	nl-ze-axl	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-axl
Baarland	Borsele	nl-ze-bra	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-bra
Biervliet	Sluis	nl-ze-brv	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-brv
Biervliet	Terneuzen	nl-ze-tnz	nl,nl-ze,nl-mdl,nl-ze-tnz
Biggekerke	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver
Borssele	Borsele	nl-ze-bor	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-bor
Breskens	Sluis	nl-ze-brs	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-brs
Brouwershaven	Schouwen-Duiveland	nl-ze-bro	nl,nl-ze,nl-zh,nl-mdl,nl-ze-swd,nl-ze-bro
Bruinisse	Schouwen-Duiveland	nl-ze-bse	nl,nl-ze,nl-zh,nl-bzm,nl-ze-swd,nl-ze-bse
Burgh-Haamstede	Schouwen-Duiveland	nl-ze-swd	nl,nl-ze,nl-mdl,nl-ze-swd
Cadzand	Sluis	nl-ze-czd	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-czd
Clinge	Hulst	nl-ze-cli	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-cli
Colijnsplaat	Noord-Beveland	nl-ze-col	nl,nl-ze,nl-mdl,nl-ze-noq,nl-ze-col
Domburg	Veere	nl-ze-dbr	nl,nl-ze,nl-mdl,nl-ze-ver,nl-ze-dbr
Dreischor	Schouwen-Duiveland	nl-ze-nd5	nl,nl-ze,nl-zh,nl-bzm,nl-mdl,nl-ze-swd,nl-ze-nd5
Driewegen	Borsele	nl-ze-d8z	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-d8z
Eede	Sluis	nl-ze-eed	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-eed
Ellemeet	Schouwen-Duiveland	nl-ze-eet	nl,nl-ze,nl-mdl,nl-ze-swd,nl-ze-eet
Ellewoutsdijk	Borsele	nl-ze-bor	nl,nl-ze,nl-mdl,nl-ze-bor
Gapinge	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver
Geersdijk	Noord-Beveland	nl-ze-noq	nl,nl-ze,nl-mdl,nl-ze-noq
Goes	Goes	nl-ze-goe	nl,nl-ze,nl-mdl,nl-ze-goe,nl-ze-goe
Graauw	Hulst	nl-ze-hul	nl,nl-ze,nl-bzm,nl-ze-hul
Grijpskerke	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver
Groede	Sluis	nl-ze-grd	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-grd
Hansweert	Reimerswaal	nl-ze-rew	nl,nl-ze,nl-bzm,nl-ze-rew
Heikant	Hulst	nl-ze-hkt	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-hkt
Heinkenszand	Borsele	nl-ze-bor	nl,nl-ze,nl-mdl,nl-ze-bor
Hengstdijk	Hulst	nl-ze-hnz	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-hnz
Hoedekenskerke	Borsele	nl-ze-bor	nl,nl-ze,nl-mdl,nl-ze-bor
Hoek	Terneuzen	nl-ze-zax	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-zax
Hoofdplaat	Sluis	nl-ze-hpl	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-hpl
Hulst	Hulst	nl-ze-hul	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-hul
IJzendijke	Sluis	nl-ze-izd	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-izd
Kamperland	Noord-Beveland	nl-ze-kad	nl,nl-ze,nl-mdl,nl-ze-noq,nl-ze-kad
Kapelle	Kapelle	nl-ze-kpl	nl,nl-ze,nl-bzm,nl-mdl,nl-ze-kpl,nl-ze-kpl
Kapellebrug	Hulst	nl-ze-kap	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-kap
Kats	Noord-Beveland	nl-ze-kat	nl,nl-ze,nl-mdl,nl-ze-noq,nl-ze-kat
Kattendijke	Goes	nl-ze-goe	nl,nl-ze,nl-mdl,nl-bzm,nl-ze-goe
Kerkwerve	Schouwen-Duiveland	nl-ze-swd	nl,nl-ze,nl-mdl,nl-ze-swd
Kloetinge	Kapelle	nl-ze-kot	nl,nl-ze,nl-mdl,nl-ze-kpl,nl-ze-kot
Kloetinge	Goes	nl-ze-goe	nl,nl-ze,nl-mdl,nl-ze-goe
Kloosterzande	Hulst	nl-ze-klt	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-klt
Koewacht	Terneuzen	nl-ze-kwt	nl,nl-ze,nl-bzm,nl-mdl,nl-ze-tnz,nl-ze-kwt
Kortgene	Noord-Beveland	nl-ze-kog	nl,nl-ze,nl-mdl,nl-ze-noq,nl-ze-kog
Koudekerke	Veere	nl-ze-kok	nl,nl-ze,nl-mdl,nl-ze-ver,nl-ze-kok
Krabbendijke	Reimerswaal	nl-ze-ijk	nl,nl-ze,nl-bzm,nl-ze-rew,nl-ze-ijk
Kruiningen	Reimerswaal	nl-ze-kru	nl,nl-ze,nl-bzm,nl-ze-rew,nl-ze-kru
Kuitaart	Hulst	nl-ze-hul	nl,nl-ze,nl-bzm,nl-ze-hul
Kwadendamme	Borsele	nl-ze-kwa	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-kwa
Lamswaarde	Hulst	nl-ze-hul	nl,nl-ze,nl-bzm,nl-ze-hul
Lewedorp	Borsele	nl-ze-lwd	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-lwd
Meliskerke	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver
Middelburg	Middelburg	nl-ze-mdl	nl,nl-ze,nl-mdl,nl-ze-mdl,nl-ze-mdl
Nieuw Namen	Hulst	nl-ze-hul	nl,nl-ze,nl-bzm,nl-ze-hul
Nieuw- en Sint Joosland	Middelburg	nl-ze-mdl	nl,nl-ze,nl-mdl,nl-ze-mdl
Nieuwdorp	Borsele	nl-ze-niu	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-niu
Nieuwerkerk	Schouwen-Duiveland	nl-ze-nrk	nl,nl-ze,nl-zh,nl-bzm,nl-ze-swd,nl-ze-nrk
Nieuwvliet	Sluis	nl-ze-sls	nl,nl-ze,nl-mdl,nl-ze-sls
Nisse	Borsele	nl-ze-nss	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-nss
Noordgouwe	Schouwen-Duiveland	nl-ze-nwe	nl,nl-ze,nl-mdl,nl-bzm,nl-ze-swd,nl-ze-nwe
Noordwelle	Schouwen-Duiveland	nl-ze-nwj	nl,nl-ze,nl-mdl,nl-ze-swd,nl-ze-nwj
Oost-Souburg	Vlissingen	nl-ze-oso	nl,nl-ze,nl-mdl,nl-ze-vli,nl-ze-oso
Oostburg	Sluis	nl-ze-obg	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-obg
Oostdijk	Reimerswaal	nl-ze-osd	nl,nl-ze,nl-bzm,nl-ze-rew,nl-ze-osd
Oosterland	Schouwen-Duiveland	nl-ze-otl	nl,nl-ze,nl-zh,nl-bzm,nl-ze-swd,nl-ze-otl
Oostkapelle	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver
Ossenisse	Hulst	nl-ze-hul	nl,nl-ze,nl-bzm,nl-ze-hul
Oud-Vossemeer	Tholen	nl-ze-ovm	nl,nl-ze,nl-nb,nl-bzm,nl-ze-tho,nl-ze-ovm
Oudelande	Borsele	nl-ze-bor	nl,nl-ze,nl-mdl,nl-ze-bor
Ouwerkerk	Schouwen-Duiveland	nl-ze-owk	nl,nl-ze,nl-bzm,nl-ze-swd,nl-ze-owk
Overslag	Terneuzen	nl-ze-tnz	nl,nl-ze,nl-mdl,nl-bzm,nl-ze-tnz
Ovezande	Borsele	nl-ze-ovz	nl,nl-ze,nl-mdl,nl-ze-bor,nl-ze-ovz
Philippine	Terneuzen	nl-ze-zbm	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-zbm
Poortvliet	Tholen	nl-ze-pvt	nl,nl-ze,nl-nb,nl-bzm,nl-ze-tho,nl-ze-pvt
Renesse	Schouwen-Duiveland	nl-ze-rns	nl,nl-ze,nl-mdl,nl-ze-swd,nl-ze-rns
Retranchement	Sluis	nl-ze-ret	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-ret
Rilland	Reimerswaal	nl-ze-rla	nl,nl-ze,nl-nb,nl-bzm,nl-ze-rew,nl-ze-rla
Ritthem	Vlissingen	nl-ze-rtt	nl,nl-ze,nl-mdl,nl-ze-vli,nl-ze-rtt
Sas van Gent	Terneuzen	nl-ze-svg	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-svg
Scharendijke	Schouwen-Duiveland	nl-ze-srd	nl,nl-ze,nl-mdl,nl-ze-swd,nl-ze-srd
Scherpenisse	Tholen	nl-ze-ze5	nl,nl-ze,nl-nb,nl-bzm,nl-ze-tho,nl-ze-ze5
Schoondijke	Sluis	nl-ze-sco	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-sco
Schore	Kapelle	nl-ze-kpl	nl,nl-ze,nl-bzm,nl-ze-kpl
Serooskerke	Veere	nl-ze-ser	nl,nl-ze,nl-mdl,nl-ze-ver,nl-ze-ser
Sint Jansteen	Hulst	nl-ze-tee	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-tee
Sint Kruis	Sluis	nl-ze-sls	nl,nl-ze,nl-mdl,nl-ze-sls
Sint Philipsland	Tholen	nl-ze-plp	nl,nl-ze,nl-nb,nl-zh,nl-bzm,nl-ze-tho,nl-ze-plp
Sint-Annaland	Tholen	nl-ze-snn	nl,nl-ze,nl-nb,nl-bzm,nl-ze-tho,nl-ze-snn
Sint-Maartensdijk	Tholen	nl-ze-tho	nl,nl-ze,nl-bzm,nl-ze-tho
Sirjansland	Schouwen-Duiveland	nl-ze-srj	nl,nl-ze,nl-zh,nl-bzm,nl-ze-swd,nl-ze-srj
Sluis	Sluis	nl-ze-sls	nl,nl-ze,nl-mdl,nl-ze-sls,nl-ze-sls
Sluiskil	Terneuzen	nl-ze-slu	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-slu
Spui	Terneuzen	nl-ze-tnz	nl,nl-ze,nl-mdl,nl-ze-tnz
Stavenisse	Tholen	nl-ze-svn	nl,nl-ze,nl-bzm,nl-ze-tho,nl-ze-svn
Terhole	Hulst	nl-ze-hul	nl,nl-ze,nl-bzm,nl-ze-hul
Terneuzen	Terneuzen	nl-ze-tnz	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-tnz
Tholen	Tholen	nl-ze-tho	nl,nl-ze,nl-nb,nl-bzm,nl-ze-tho,nl-ze-tho
Veere	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver,nl-ze-ver
Vlissingen	Vlissingen	nl-ze-vli	nl,nl-ze,nl-mdl,nl-ze-vli,nl-ze-vli
Vogelwaarde	Hulst	nl-ze-vlw	nl,nl-ze,nl-bzm,nl-mdl,nl-ze-hul,nl-ze-vlw
Vrouwenpolder	Veere	nl-ze-ver	nl,nl-ze,nl-mdl,nl-ze-ver
Waarde	Reimerswaal	nl-ze-wde	nl,nl-ze,nl-bzm,nl-ze-rew,nl-ze-wde
Walsoorden	Hulst	nl-ze-wso	nl,nl-ze,nl-bzm,nl-ze-hul,nl-ze-wso
Waterlandkerkje	Sluis	nl-ze-sls	nl,nl-ze,nl-mdl,nl-ze-sls
Wemeldinge	Kapelle	nl-ze-wed	nl,nl-ze,nl-bzm,nl-ze-kpl,nl-ze-wed
Westdorpe	Terneuzen	nl-ze-wdp	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-wdp
Westkapelle	Veere	nl-ze-wkp	nl,nl-ze,nl-mdl,nl-ze-ver,nl-ze-wkp
Wilhelminadorp	Goes	nl-ze-whd	nl,nl-ze,nl-mdl,nl-ze-goe,nl-ze-whd
Wissenkerke	Noord-Beveland	nl-ze-wze	nl,nl-ze,nl-mdl,nl-ze-noq,nl-ze-wze
Wolphaartsdijk	Goes	nl-ze-goe	nl,nl-ze,nl-mdl,nl-ze-goe
Yerseke	Reimerswaal	nl-ze-ysk	nl,nl-ze,nl-bzm,nl-ze-rew,nl-ze-ysk
Zaamslag	Terneuzen	nl-ze-zah	nl,nl-ze,nl-mdl,nl-ze-tnz,nl-ze-zah
Zierikzee	Schouwen-Duiveland	nl-ze-zie	nl,nl-ze,nl-mdl,nl-ze-swd,nl-ze-zie
Zonnemaire	Schouwen-Duiveland	nl-ze-swd	nl,nl-ze,nl-zh,nl-mdl,nl-bzm,nl-ze-swd
Zoutelande	Veere	nl-ze-zld	nl,nl-ze,nl-mdl,nl-ze-ver,nl-ze-zld
Zuiddorpe	Terneuzen	nl-ze-zby	nl,nl-ze,nl-mdl,nl-bzm,nl-ze-tnz,nl-ze-zby
Zuidzande	Sluis	nl-ze-sls	nl,nl-ze,nl-mdl,nl-ze-sls
's Gravenmoer	Dongen	nl-nb-don	nl,nl-nb,nl-brd,nl-nb-don
's-Hertogenbosch	's-Hertogenbosch	nl-nb-htb	nl,nl-nb,nl-ge,nl-htb,nl-nb-htb,nl-nb-htb
Aarle-Rixtel	Laarbeek	nl-nb-laa	nl,nl-nb,nl-hlm,nl-ein,nl-nb-laa
Achtmaal	Zundert	nl-nb-zud	nl,nl-nb,nl-roo,nl-nb-zud
Almkerk	Altena	nl-nb-akk	nl,nl-nb,nl-zh,nl-ge,nl-dor,nl-nb-wcm,nl-nb-akk
Alphen	Alphen-Chaam	nl-nb-aph	nl,nl-nb,nl-tlb,nl-nb-aac,nl-nb-aph
Andel	Altena	nl-nb-anl	nl,nl-nb,nl-ge,nl-zh,nl-htb,nl-nb-wcm,nl-nb-anl
Asten	Asten	nl-nb-ast	nl,nl-nb,nl-hlm,nl-nb-ast,nl-nb-ast
Baarle-Nassau	Baarle-Nassau	nl-nb-bns	nl,nl-nb,nl-tlb,nl-nb-bns,nl-nb-bns
Babyloniënbroek	Altena	nl-nb-wcm	nl,nl-nb,nl-ge,nl-zh,nl-htb,nl-tlb,nl-nb-wcm
Bakel	Gemert-Bakel	nl-nb-bak	nl,nl-nb,nl-li,nl-hlm,nl-nb-gba,nl-nb-bak
Bavel	Breda	nl-nb-bav	nl,nl-nb,nl-brd,nl-nb-brd,nl-nb-bav
Bavel AC	Alphen-Chaam	nl-nb-aac	nl,nl-nb,nl-brd,nl-nb-aac
Beek en Donk	Laarbeek	nl-nb-bee	nl,nl-nb,nl-hlm,nl-nb-laa,nl-nb-bee
Beers NB	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-ge,nl-li,nl-nij,nl-nb-cuy
Bergeijk	Bergeijk	nl-nb-bey	nl,nl-nb,nl-ein,nl-nb-bey,nl-nb-bey
Bergen op Zoom	Bergen op Zoom	nl-nb-bzm	nl,nl-nb,nl-ze,nl-bzm,nl-nb-bzm,nl-nb-bzm
Berghem	Oss	nl-nb-bhe	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-bhe
Berkel-Enschot	Tilburg	nl-nb-bes	nl,nl-nb,nl-tlb,nl-nb-tlb,nl-nb-bes
Berlicum	Sint-Michielsgestel	nl-nb-blu	nl,nl-nb,nl-ge,nl-htb,nl-oss,nl-nb-smg,nl-nb-blu
Best	Best	nl-nb-bst	nl,nl-nb,nl-ein,nl-nb-bst,nl-nb-bst
Beugen	Land van Cuijk	nl-nb-beu	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-beu
Biest-Houtakker	Hilvarenbeek	nl-nb-hvk	nl,nl-nb,nl-tlb,nl-nb-hvk
Biezenmortel	Tilburg	nl-nb-bzo	nl,nl-nb,nl-tlb,nl-htb,nl-nb-tlb,nl-nb-bzo
Bladel	Bladel	nl-nb-bll	nl,nl-nb,nl-ein,nl-nb-bll,nl-nb-bll
Boekel	Boekel	nl-nb-bel	nl,nl-nb,nl-hlm,nl-nb-bel,nl-nb-bel
Bosschenhoofd	Halderberge	nl-nb-bos	nl,nl-nb,nl-roo,nl-nb-hdb,nl-nb-bos
Boxmeer	Land van Cuijk	nl-nb-box	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-box
Boxtel	Boxtel	nl-nb-bxt	nl,nl-nb,nl-htb,nl-nb-bxt,nl-nb-bxt
Breda	Breda	nl-nb-brd	nl,nl-nb,nl-brd,nl-nb-brd,nl-nb-brd
Budel	Cranendonck	nl-nb-bud	nl,nl-nb,nl-li,nl-wrt,nl-nb-crk,nl-nb-bud
Budel-Dorplein	Cranendonck	nl-nb-crk	nl,nl-nb,nl-li,nl-wrt,nl-nb-crk
Budel-Schoot	Cranendonck	nl-nb-crk	nl,nl-nb,nl-li,nl-wrt,nl-nb-crk
Castelre	Baarle-Nassau	nl-nb-bns	nl,nl-nb,nl-brd,nl-nb-bns
Casteren	Bladel	nl-nb-bll	nl,nl-nb,nl-ein,nl-nb-bll
Chaam	Alphen-Chaam	nl-nb-caa	nl,nl-nb,nl-brd,nl-nb-aac,nl-nb-caa
Cromvoirt	Vught	nl-nb-vgt	nl,nl-nb,nl-ge,nl-htb,nl-nb-vgt
Cuijk	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-ge,nl-nij,nl-nb-cuy,nl-nb-cuy
De Heen	Steenbergen	nl-nb-dhe	nl,nl-nb,nl-ze,nl-zh,nl-bzm,nl-nb-ste,nl-nb-dhe
De Moer	Loon op Zand	nl-nb-dm9	nl,nl-nb,nl-tlb,nl-nb-loz,nl-nb-dm9
De Mortel	Gemert-Bakel	nl-nb-gba	nl,nl-nb,nl-hlm,nl-nb-gba
De Rips	Gemert-Bakel	nl-nb-rip	nl,nl-nb,nl-li,nl-vnr,nl-hlm,nl-nb-gba,nl-nb-rip
Demen	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Den Dungen	Sint-Michielsgestel	nl-nb-smg	nl,nl-nb,nl-ge,nl-htb,nl-nb-smg
Den Hout	Oosterhout	nl-nb-nb4	nl,nl-nb,nl-brd,nl-nb-oos,nl-nb-nb4
Deurne	Deurne	nl-nb-deu	nl,nl-nb,nl-li,nl-hlm,nl-nb-deu,nl-nb-deu
Deursen-Dennenburg	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Dieden	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Diessen	Hilvarenbeek	nl-nb-dse	nl,nl-nb,nl-tlb,nl-nb-hvk,nl-nb-dse
Dinteloord	Steenbergen	nl-nb-din	nl,nl-nb,nl-zh,nl-roo,nl-nb-ste,nl-nb-din
Doeveren	Heusden	nl-nb-hes	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes
Dongen	Dongen	nl-nb-don	nl,nl-nb,nl-brd,nl-tlb,nl-nb-don,nl-nb-don
Dorst	Oosterhout	nl-nb-drs	nl,nl-nb,nl-brd,nl-nb-oos,nl-nb-drs
Drimmelen	Drimmelen	nl-nb-drm	nl,nl-nb,nl-brd,nl-nb-drm,nl-nb-drm
Drongelen	Altena	nl-nb-wcm	nl,nl-nb,nl-ge,nl-htb,nl-tlb,nl-nb-wcm
Drunen	Heusden	nl-nb-drn	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-drn
Duizel	Eersel	nl-nb-duz	nl,nl-nb,nl-ein,nl-nb-qct,nl-nb-duz
Dussen	Altena	nl-nb-dus	nl,nl-nb,nl-ge,nl-brd,nl-tlb,nl-dor,nl-nb-wcm,nl-nb-dus
Eersel	Eersel	nl-nb-qct	nl,nl-nb,nl-ein,nl-nb-qct,nl-nb-qct
Eethen	Altena	nl-nb-wcm	nl,nl-nb,nl-ge,nl-htb,nl-tlb,nl-nb-wcm
Eindhoven	Eindhoven	nl-nb-ein	nl,nl-nb,nl-ein,nl-nb-ein,nl-nb-ein
Elsendorp	Gemert-Bakel	nl-nb-els	nl,nl-nb,nl-li,nl-hlm,nl-nb-gba,nl-nb-els
Elshout	Heusden	nl-nb-bbt	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-bbt
Erp	Meierijstad	nl-nb-erp	nl,nl-nb,nl-hlm,nl-nb-veg,nl-nb-erp
Esbeek	Hilvarenbeek	nl-nb-esb	nl,nl-nb,nl-tlb,nl-nb-hvk,nl-nb-esb
Esch	Boxtel	nl-nb-bxt	nl,nl-nb,nl-htb,nl-nb-bxt
Escharen	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-ge,nl-li,nl-nij,nl-nb-cuy
Etten-Leur	Etten-Leur	nl-nb-ett	nl,nl-nb,nl-brd,nl-roo,nl-nb-ett
Fijnaart	Moerdijk	nl-nb-ffj	nl,nl-nb,nl-zh,nl-roo,nl-nb-moe,nl-nb-ffj
Galder	Alphen-Chaam	nl-nb-aac	nl,nl-nb,nl-brd,nl-nb-aac
Gassel	Land van Cuijk	nl-nb-gas	nl,nl-nb,nl-ge,nl-li,nl-nij,nl-nb-cuy,nl-nb-gas
Gastel	Cranendonck	nl-nb-crk	nl,nl-nb,nl-wrt,nl-nb-crk
Geertruidenberg	Geertruidenberg	nl-nb-gtb	nl,nl-nb,nl-brd,nl-nb-gtb,nl-nb-gtb
Geffen	Oss	nl-nb-gfn	nl,nl-nb,nl-ge,nl-oss,nl-htb,nl-nb-oss,nl-nb-gfn
Geldrop	Geldrop-Mierlo	nl-nb-gld	nl,nl-nb,nl-ein,nl-hlm,nl-nb-gom,nl-nb-gld
Gemert	Gemert-Bakel	nl-nb-gem	nl,nl-nb,nl-hlm,nl-nb-gba,nl-nb-gem
Gemonde	Sint-Michielsgestel	nl-nb-gmd	nl,nl-nb,nl-htb,nl-nb-smg,nl-nb-gmd
Genderen	Altena	nl-nb-gnd	nl,nl-nb,nl-ge,nl-htb,nl-nb-wcm,nl-nb-gnd
Giessen	Altena	nl-nb-gis	nl,nl-nb,nl-ge,nl-zh,nl-htb,nl-nb-wcm,nl-nb-gis
Gilze	Gilze en Rijen	nl-nb-gze	nl,nl-nb,nl-tlb,nl-brd,nl-nb-giz,nl-nb-gze
Goirle	Goirle	nl-nb-goi	nl,nl-nb,nl-tlb,nl-nb-goi,nl-nb-goi
Grave	Land van Cuijk	nl-nb-gav	nl,nl-nb,nl-ge,nl-li,nl-nij,nl-nb-cuy,nl-nb-gav
Groeningen	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy
Haaren	Oisterwijk	nl-nb-hra	nl,nl-nb,nl-tlb,nl-htb,nl-nb-oiw,nl-nb-hra
Haarsteeg	Heusden	nl-nb-hse	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-hse
Haghorst	Hilvarenbeek	nl-nb-hst	nl,nl-nb,nl-tlb,nl-nb-hvk,nl-nb-hst
Halsteren	Bergen op Zoom	nl-nb-hal	nl,nl-nb,nl-ze,nl-bzm,nl-roo,nl-nb-bzm,nl-nb-hal
Handel	Gemert-Bakel	nl-nb-had	nl,nl-nb,nl-hlm,nl-nb-gba,nl-nb-had
Hank	Altena	nl-nb-hnk	nl,nl-nb,nl-dor,nl-brd,nl-nb-wcm,nl-nb-hnk
Hapert	Bladel	nl-nb-hap	nl,nl-nb,nl-ein,nl-nb-bll,nl-nb-hap
Haps	Land van Cuijk	nl-nb-hps	nl,nl-nb,nl-li,nl-ge,nl-nij,nl-nb-cuy,nl-nb-hps
Haren	Oss	nl-nb-hre	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-hre
Hedikhuizen	Heusden	nl-nb-hhu	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-hhu
Heerle	Roosendaal	nl-nb-hle	nl,nl-nb,nl-ze,nl-bzm,nl-roo,nl-nb-roo,nl-nb-hle
Heesbeen	Heusden	nl-nb-hbn	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-hbn
Heesch	Bernheze	nl-nb-hec	nl,nl-nb,nl-ge,nl-oss,nl-nb-eez,nl-nb-hec
Heeswijk-Dinther	Bernheze	nl-nb-eez	nl,nl-nb,nl-htb,nl-oss,nl-nb-eez
Heeze	Heeze-Leende	nl-nb-hze	nl,nl-nb,nl-ein,nl-hlm,nl-nb-hez,nl-nb-hze
Heijningen	Moerdijk	nl-nb-hjy	nl,nl-nb,nl-zh,nl-roo,nl-nb-moe,nl-nb-hjy
Helenaveen	Deurne	nl-nb-deu	nl,nl-nb,nl-li,nl-vnr,nl-nb-deu
Helmond	Helmond	nl-nb-hlm	nl,nl-nb,nl-hlm,nl-nb-hlm,nl-nb-hlm
Helvoirt	Vught	nl-nb-hvo	nl,nl-nb,nl-htb,nl-tlb,nl-nb-vgt,nl-nb-hvo
Herpen	Oss	nl-nb-hpn	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-hpn
Herpt	Heusden	nl-nb-hes	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes
Heukelom	Oisterwijk	nl-nb-oiw	nl,nl-nb,nl-tlb,nl-nb-oiw
Heusden	Asten	nl-nb-ast	nl,nl-nb,nl-li,nl-hlm,nl-nb-ast
Heusden	Heusden	nl-nb-hes	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-hes
Hilvarenbeek	Hilvarenbeek	nl-nb-hvk	nl,nl-nb,nl-tlb,nl-nb-hvk,nl-nb-hvk
Hoeven	Halderberge	nl-nb-hon	nl,nl-nb,nl-roo,nl-brd,nl-nb-hdb,nl-nb-hon
Holthees	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy
Hooge Mierde	Reusel-De Mierden	nl-nb-hmd	nl,nl-nb,nl-tlb,nl-nb-rdm,nl-nb-hmd
Hooge Zwaluwe	Drimmelen	nl-nb-hoz	nl,nl-nb,nl-brd,nl-nb-drm,nl-nb-hoz
Hoogeloon	Bladel	nl-nb-ho2	nl,nl-nb,nl-ein,nl-nb-bll,nl-nb-ho2
Hoogerheide	Woensdrecht	nl-nb-hoh	nl,nl-nb,nl-ze,nl-bzm,nl-nb-woe,nl-nb-hoh
Huijbergen	Woensdrecht	nl-nb-woe	nl,nl-nb,nl-bzm,nl-roo,nl-nb-woe
Huisseling	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Hulsel	Reusel-De Mierden	nl-nb-rdm	nl,nl-nb,nl-tlb,nl-ein,nl-nb-rdm
Hulten	Gilze en Rijen	nl-nb-giz	nl,nl-nb,nl-tlb,nl-brd,nl-nb-giz
Kaatsheuvel	Loon op Zand	nl-nb-kts	nl,nl-nb,nl-tlb,nl-nb-loz,nl-nb-kts
Katwijk NB	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-ge,nl-nij,nl-nb-cuy
Keent	Oss	nl-nb-knt	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-knt
Klein Zundert	Zundert	nl-nb-zud	nl,nl-nb,nl-brd,nl-roo,nl-nb-zud
Klundert	Moerdijk	nl-nb-klu	nl,nl-nb,nl-zh,nl-roo,nl-nb-moe,nl-nb-klu
Knegsel	Eersel	nl-nb-qct	nl,nl-nb,nl-ein,nl-nb-qct
Kruisland	Steenbergen	nl-nb-kld	nl,nl-nb,nl-roo,nl-bzm,nl-nb-ste,nl-nb-kld
Lage Mierde	Reusel-De Mierden	nl-nb-lmi	nl,nl-nb,nl-tlb,nl-nb-rdm,nl-nb-lmi
Lage Zwaluwe	Drimmelen	nl-nb-lza	nl,nl-nb,nl-zh,nl-dor,nl-nb-drm,nl-nb-lza
Landhorst	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy
Langenboom	Land van Cuijk	nl-nb-lab	nl,nl-nb,nl-ge,nl-oss,nl-nb-cuy,nl-nb-lab
Langeweg	Moerdijk	nl-nb-lwg	nl,nl-nb,nl-zh,nl-brd,nl-nb-moe,nl-nb-lwg
Ledeacker	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy
Leende	Heeze-Leende	nl-nb-nde	nl,nl-nb,nl-ein,nl-nb-hez,nl-nb-nde
Lepelstraat	Bergen op Zoom	nl-nb-lep	nl,nl-nb,nl-ze,nl-bzm,nl-roo,nl-nb-bzm,nl-nb-lep
Liempde	Boxtel	nl-nb-lmp	nl,nl-nb,nl-htb,nl-nb-bxt,nl-nb-lmp
Lierop	Someren	nl-nb-lrp	nl,nl-nb,nl-hlm,nl-ein,nl-nb-som,nl-nb-lrp
Lieshout	Laarbeek	nl-nb-lsh	nl,nl-nb,nl-hlm,nl-ein,nl-nb-laa,nl-nb-lsh
Liessel	Deurne	nl-nb-lsl	nl,nl-nb,nl-li,nl-hlm,nl-nb-deu,nl-nb-lsl
Linden	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-ge,nl-li,nl-nij,nl-nb-cuy
Lith	Oss	nl-nb-lit	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-lit
Lithoijen	Oss	nl-nb-lto	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-lto
Loon op Zand	Loon op Zand	nl-nb-loz	nl,nl-nb,nl-tlb,nl-nb-loz,nl-nb-loz
Loosbroek	Bernheze	nl-nb-lsb	nl,nl-nb,nl-oss,nl-nb-eez,nl-nb-lsb
Luyksgestel	Bergeijk	nl-nb-lyg	nl,nl-nb,nl-ein,nl-nb-bey,nl-nb-lyg
Maarheeze	Cranendonck	nl-nb-mhz	nl,nl-nb,nl-li,nl-wrt,nl-nb-crk,nl-nb-mhz
Maashees	Land van Cuijk	nl-nb-maa	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-maa
Macharen	Oss	nl-nb-mac	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-mac
Made	Drimmelen	nl-nb-qdj	nl,nl-nb,nl-brd,nl-nb-drm,nl-nb-qdj
Maren-Kessel	Oss	nl-nb-mrk	nl,nl-nb,nl-ge,nl-oss,nl-htb,nl-nb-oss,nl-nb-mrk
Mariahout	Laarbeek	nl-nb-mho	nl,nl-nb,nl-hlm,nl-ein,nl-nb-laa,nl-nb-mho
Meeuwen	Altena	nl-nb-mwe	nl,nl-nb,nl-ge,nl-tlb,nl-htb,nl-nb-wcm,nl-nb-mwe
Megen	Oss	nl-nb-mgn	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-mgn
Mierlo	Geldrop-Mierlo	nl-nb-mie	nl,nl-nb,nl-hlm,nl-ein,nl-nb-gom,nl-nb-mie
Milheeze	Gemert-Bakel	nl-nb-mze	nl,nl-nb,nl-li,nl-hlm,nl-vnr,nl-nb-gba,nl-nb-mze
Mill	Land van Cuijk	nl-nb-mll	nl,nl-nb,nl-ge,nl-li,nl-nij,nl-oss,nl-nb-cuy,nl-nb-mll
Moerdijk	Moerdijk	nl-nb-moe	nl,nl-nb,nl-zh,nl-dor,nl-nb-moe,nl-nb-moe
Moergestel	Oisterwijk	nl-nb-mgs	nl,nl-nb,nl-tlb,nl-nb-oiw,nl-nb-mgs
Moerstraten	Roosendaal	nl-nb-msn	nl,nl-nb,nl-ze,nl-bzm,nl-roo,nl-nb-roo,nl-nb-msn
Molenschot	Gilze en Rijen	nl-nb-mot	nl,nl-nb,nl-brd,nl-nb-giz,nl-nb-mot
Neerkant	Deurne	nl-nb-deu	nl,nl-nb,nl-li,nl-wrt,nl-nb-deu
Neerlangel	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Neerloon	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Netersel	Bladel	nl-nb-bll	nl,nl-nb,nl-tlb,nl-ein,nl-nb-bll
Nieuw-Vossemeer	Steenbergen	nl-nb-nvo	nl,nl-nb,nl-ze,nl-bzm,nl-nb-ste,nl-nb-nvo
Nieuwendijk	Altena	nl-nb-wcm	nl,nl-nb,nl-zh,nl-dor,nl-nb-wcm
Nieuwkuijk	Heusden	nl-nb-nku	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-nku
Nispen	Roosendaal	nl-nb-nis	nl,nl-nb,nl-roo,nl-bzm,nl-nb-roo,nl-nb-nis
Nistelrode	Bernheze	nl-nb-ntr	nl,nl-nb,nl-oss,nl-nb-eez,nl-nb-ntr
Noordhoek	Moerdijk	nl-nb-ndh	nl,nl-nb,nl-zh,nl-roo,nl-nb-moe,nl-nb-ndh
Nuenen	Nuenen, Gerwen en Nederwetten	nl-nb-ngn	nl,nl-nb,nl-ein,nl-hlm,nl-nb-ngn,nl-nb-ngn
Nuland	's-Hertogenbosch	nl-nb-nul	nl,nl-nb,nl-ge,nl-oss,nl-htb,nl-nb-htb,nl-nb-nul
Odiliapeel	Maashorst	nl-nb-odl	nl,nl-nb,nl-oss,nl-hlm,nl-nb-ude,nl-nb-odl
Oeffelt	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-ge,nl-nij,nl-nb-cuy
Oijen	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Oirschot	Oirschot	nl-nb-oih	nl,nl-nb,nl-ein,nl-nb-oih,nl-nb-oih
Oisterwijk	Oisterwijk	nl-nb-oiw	nl,nl-nb,nl-tlb,nl-nb-oiw,nl-nb-oiw
Ommel	Asten	nl-nb-oml	nl,nl-nb,nl-li,nl-hlm,nl-nb-ast,nl-nb-oml
Oost West en Middelbeers	Oirschot	nl-nb-oih	nl,nl-nb,nl-tlb,nl-ein,nl-nb-oih
Oosteind	Oosterhout	nl-nb-ooe	nl,nl-nb,nl-brd,nl-nb-oos,nl-nb-ooe
Oosterhout	Oosterhout	nl-nb-oos	nl,nl-nb,nl-brd,nl-nb-oos,nl-nb-oos
Oploo	Land van Cuijk	nl-nb-opl	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-opl
Oss	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-oss
Ossendrecht	Woensdrecht	nl-nb-osh	nl,nl-nb,nl-bzm,nl-nb-woe,nl-nb-osh
Oud Gastel	Halderberge	nl-nb-hdb	nl,nl-nb,nl-roo,nl-nb-hdb
Oudemolen	Moerdijk	nl-nb-omo	nl,nl-nb,nl-zh,nl-roo,nl-nb-moe,nl-nb-omo
Oudenbosch	Halderberge	nl-nb-obo	nl,nl-nb,nl-roo,nl-nb-hdb,nl-nb-obo
Oudheusden	Heusden	nl-nb-hes	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes
Overlangel	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Overloon	Land van Cuijk	nl-nb-ovl	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-ovl
Prinsenbeek	Breda	nl-nb-prb	nl,nl-nb,nl-brd,nl-nb-brd,nl-nb-prb
Putte	Woensdrecht	nl-nb-put	nl,nl-nb,nl-bzm,nl-nb-woe,nl-nb-put
Raamsdonk	Geertruidenberg	nl-nb-gtb	nl,nl-nb,nl-brd,nl-nb-gtb
Raamsdonksveer	Geertruidenberg	nl-nb-raa	nl,nl-nb,nl-brd,nl-nb-gtb,nl-nb-raa
Ravenstein	Oss	nl-nb-ras	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss,nl-nb-ras
Reek	Maashorst	nl-nb-rek	nl,nl-nb,nl-ge,nl-oss,nl-nb-ude,nl-nb-rek
Reusel	Reusel-De Mierden	nl-nb-rdm	nl,nl-nb,nl-tlb,nl-ein,nl-nb-rdm
Riel	Goirle	nl-nb-rie	nl,nl-nb,nl-tlb,nl-nb-goi,nl-nb-rie
Riethoven	Bergeijk	nl-nb-rth	nl,nl-nb,nl-ein,nl-nb-bey,nl-nb-rth
Rijen	Gilze en Rijen	nl-nb-rje	nl,nl-nb,nl-brd,nl-tlb,nl-nb-giz,nl-nb-rje
Rijkevoort	Land van Cuijk	nl-nb-rjv	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-rjv
Rijkevoort-De Walsert	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy
Rijsbergen	Zundert	nl-nb-ryb	nl,nl-nb,nl-brd,nl-nb-zud,nl-nb-ryb
Rijswijk (NB)	Altena	nl-nb-wcm	nl,nl-nb,nl-zh,nl-ge,nl-htb,nl-dor,nl-nb-wcm
Roosendaal	Roosendaal	nl-nb-roo	nl,nl-nb,nl-roo,nl-nb-roo,nl-nb-roo
Rosmalen	's-Hertogenbosch	nl-nb-rma	nl,nl-nb,nl-ge,nl-htb,nl-oss,nl-nb-htb,nl-nb-rma
Rucphen	Rucphen	nl-nb-rcp	nl,nl-nb,nl-roo,nl-nb-rcp,nl-nb-rcp
Sambeek	Land van Cuijk	nl-nb-smb	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-smb
Schaijk	Maashorst	nl-nb-scj	nl,nl-nb,nl-ge,nl-oss,nl-nb-ude,nl-nb-scj
Schijf	Rucphen	nl-nb-scy	nl,nl-nb,nl-roo,nl-nb-rcp,nl-nb-scy
Schijndel	Meierijstad	nl-nb-snd	nl,nl-nb,nl-htb,nl-nb-veg,nl-nb-snd
Sint Agatha	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-ge,nl-nij,nl-nb-cuy
Sint Anthonis	Land van Cuijk	nl-nb-sin	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-sin
Sint Hubert	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-ge,nl-nij,nl-vnr,nl-nb-cuy
Sint-Michielsgestel	Sint-Michielsgestel	nl-nb-smg	nl,nl-nb,nl-htb,nl-nb-smg
Sint-Oedenrode	Meierijstad	nl-nb-veg	nl,nl-nb,nl-ein,nl-nb-veg
Sleeuwijk	Altena	nl-nb-swk	nl,nl-nb,nl-zh,nl-ge,nl-dor,nl-nb-wcm,nl-nb-swk
Soerendonk	Cranendonck	nl-nb-crk	nl,nl-nb,nl-wrt,nl-nb-crk
Someren	Someren	nl-nb-som	nl,nl-nb,nl-hlm,nl-nb-som,nl-nb-som
Son en Breugel	Son en Breugel	nl-nb-sbr	nl,nl-nb,nl-ein,nl-hlm,nl-nb-sbr,nl-nb-sbr
Sprang-Capelle	Waalwijk	nl-nb-spc	nl,nl-nb,nl-tlb,nl-nb-wlk,nl-nb-spc
Sprundel	Rucphen	nl-nb-spr	nl,nl-nb,nl-roo,nl-brd,nl-nb-rcp,nl-nb-spr
St. Willebrord	Rucphen	nl-nb-rcp	nl,nl-nb,nl-roo,nl-brd,nl-nb-rcp
Stampersgat	Halderberge	nl-nb-spg	nl,nl-nb,nl-zh,nl-roo,nl-nb-hdb,nl-nb-spg
Standdaarbuiten	Moerdijk	nl-nb-sdb	nl,nl-nb,nl-roo,nl-nb-moe,nl-nb-sdb
Steenbergen	Steenbergen	nl-nb-ste	nl,nl-nb,nl-ze,nl-bzm,nl-roo,nl-nb-ste,nl-nb-ste
Steensel	Eersel	nl-nb-qct	nl,nl-nb,nl-ein,nl-nb-qct
Sterksel	Heeze-Leende	nl-nb-str	nl,nl-nb,nl-wrt,nl-ein,nl-nb-hez,nl-nb-str
Stevensbeek	Land van Cuijk	nl-nb-stb	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-stb
Strijbeek	Alphen-Chaam	nl-nb-sjb	nl,nl-nb,nl-brd,nl-nb-aac,nl-nb-sjb
Teeffelen	Oss	nl-nb-oss	nl,nl-nb,nl-ge,nl-oss,nl-nb-oss
Terheijden	Drimmelen	nl-nb-ter	nl,nl-nb,nl-brd,nl-nb-drm,nl-nb-ter
Teteringen	Breda	nl-nb-tet	nl,nl-nb,nl-brd,nl-nb-brd,nl-nb-tet
Tilburg	Tilburg	nl-nb-tlb	nl,nl-nb,nl-tlb,nl-nb-tlb,nl-nb-tlb
Uden	Maashorst	nl-nb-ude	nl,nl-nb,nl-oss,nl-nb-ude,nl-nb-ude
Udenhout	Tilburg	nl-nb-udh	nl,nl-nb,nl-tlb,nl-nb-tlb,nl-nb-udh
Uitwijk	Altena	nl-nb-wcm	nl,nl-nb,nl-zh,nl-ge,nl-htb,nl-dor,nl-nb-wcm
Ulicoten	Baarle-Nassau	nl-nb-uct	nl,nl-nb,nl-brd,nl-nb-bns,nl-nb-uct
Ulvenhout	Breda	nl-nb-nbv	nl,nl-nb,nl-brd,nl-nb-brd,nl-nb-nbv
Ulvenhout AC	Alphen-Chaam	nl-nb-aac	nl,nl-nb,nl-brd,nl-nb-aac
Valkenswaard	Valkenswaard	nl-nb-val	nl,nl-nb,nl-ein,nl-nb-val,nl-nb-val
Veen	Altena	nl-nb-nev	nl,nl-nb,nl-ge,nl-zh,nl-htb,nl-nb-wcm,nl-nb-nev
Veghel	Meierijstad	nl-nb-veg	nl,nl-nb,nl-hlm,nl-oss,nl-nb-veg,nl-nb-veg
Veldhoven	Veldhoven	nl-nb-vdh	nl,nl-nb,nl-ein,nl-nb-vdh,nl-nb-vdh
Velp	Land van Cuijk	nl-nb-vep	nl,nl-nb,nl-ge,nl-oss,nl-nij,nl-nb-cuy,nl-nb-vep
Venhorst	Boekel	nl-nb-vhr	nl,nl-nb,nl-hlm,nl-nb-bel,nl-nb-vhr
Vessem	Eersel	nl-nb-vsm	nl,nl-nb,nl-ein,nl-nb-qct,nl-nb-vsm
Vianen NB	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-ge,nl-nij,nl-nb-cuy
Vierlingsbeek	Land van Cuijk	nl-nb-vie	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-vie
Vinkel	Bernheze	nl-nb-vkl	nl,nl-nb,nl-oss,nl-htb,nl-nb-eez,nl-nb-vkl
Vinkel	's-Hertogenbosch	nl-nb-htb	nl,nl-nb,nl-oss,nl-htb,nl-nb-htb
Vlierden	Deurne	nl-nb-deu	nl,nl-nb,nl-li,nl-hlm,nl-nb-deu
Vlijmen	Heusden	nl-nb-vlm	nl,nl-nb,nl-ge,nl-htb,nl-nb-hes,nl-nb-vlm
Volkel	Maashorst	nl-nb-vle	nl,nl-nb,nl-oss,nl-nb-ude,nl-nb-vle
Vorstenbosch	Bernheze	nl-nb-eez	nl,nl-nb,nl-oss,nl-nb-eez
Vortum-Mullem	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy
Vught	Vught	nl-nb-vgt	nl,nl-nb,nl-ge,nl-htb,nl-nb-vgt,nl-nb-vgt
Waalre	Waalre	nl-nb-waa	nl,nl-nb,nl-ein,nl-nb-waa,nl-nb-waa
Waalwijk	Waalwijk	nl-nb-wlk	nl,nl-nb,nl-ge,nl-tlb,nl-nb-wlk,nl-nb-wlk
Waardhuizen	Altena	nl-nb-wcm	nl,nl-nb,nl-ge,nl-zh,nl-htb,nl-dor,nl-nb-wcm
Wagenberg	Drimmelen	nl-nb-wag	nl,nl-nb,nl-brd,nl-nb-drm,nl-nb-wag
Wanroij	Land van Cuijk	nl-nb-waj	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy,nl-nb-waj
Waspik	Waalwijk	nl-nb-wpi	nl,nl-nb,nl-brd,nl-tlb,nl-nb-wlk,nl-nb-wpi
Werkendam	Altena	nl-nb-wkd	nl,nl-nb,nl-zh,nl-ge,nl-dor,nl-nb-wcm,nl-nb-wkd
Wernhout	Zundert	nl-nb-wht	nl,nl-nb,nl-roo,nl-nb-zud,nl-nb-wht
Westerbeek	Land van Cuijk	nl-nb-cuy	nl,nl-nb,nl-li,nl-vnr,nl-nb-cuy
Westerhoven	Bergeijk	nl-nb-whn	nl,nl-nb,nl-ein,nl-nb-bey,nl-nb-whn
Wijk en Aalburg	Altena	nl-nb-wea	nl,nl-nb,nl-ge,nl-htb,nl-nb-wcm,nl-nb-wea
Wilbertoord	Land van Cuijk	nl-nb-wob	nl,nl-nb,nl-vnr,nl-hlm,nl-oss,nl-nb-cuy,nl-nb-wob
Willemstad	Moerdijk	nl-nb-wis	nl,nl-nb,nl-zh,nl-roo,nl-nb-moe,nl-nb-wis
Wintelre	Eersel	nl-nb-wtr	nl,nl-nb,nl-ein,nl-nb-qct,nl-nb-wtr
Woensdrecht	Woensdrecht	nl-nb-woe	nl,nl-nb,nl-ze,nl-bzm,nl-nb-woe,nl-nb-woe
Woudrichem	Altena	nl-nb-wcm	nl,nl-nb,nl-zh,nl-ge,nl-dor,nl-htb,nl-nb-wcm,nl-nb-wcm
Wouw	Roosendaal	nl-nb-wou	nl,nl-nb,nl-roo,nl-bzm,nl-nb-roo,nl-nb-wou
Wouwse Plantage	Roosendaal	nl-nb-wpl	nl,nl-nb,nl-roo,nl-bzm,nl-nb-roo,nl-nb-wpl
Zeeland	Maashorst	nl-nb-zla	nl,nl-nb,nl-ge,nl-oss,nl-nb-ude,nl-nb-zla
Zegge	Rucphen	nl-nb-zeg	nl,nl-nb,nl-roo,nl-nb-rcp,nl-nb-zeg
Zevenbergen	Moerdijk	nl-nb-zvb	nl,nl-nb,nl-zh,nl-brd,nl-nb-moe,nl-nb-zvb
Zevenbergschen Hoek	Moerdijk	nl-nb-zbk	nl,nl-nb,nl-zh,nl-brd,nl-nb-moe,nl-nb-zbk
Zevenbergschen Hoek	Drimmelen	nl-nb-drm	nl,nl-nb,nl-zh,nl-brd,nl-nb-drm
Zundert	Zundert	nl-nb-zud	nl,nl-nb,nl-brd,nl-roo,nl-nb-zud,nl-nb-zud
Afferden L	Bergen (L)	nl-li-brx	nl,nl-li,nl-nb,nl-vnr,nl-li-brx
America	Horst aan de Maas	nl-li-zai	nl,nl-li,nl-nb,nl-vnr,nl-li-hsa,nl-li-zai
Amstenrade	Beekdaelen	nl-li-atr	nl,nl-li,nl-hen,nl-li-nth,nl-li-atr
Arcen	Venlo	nl-li-arc	nl,nl-li,nl-ven,nl-li-ven,nl-li-arc
Baarlo	Peel en Maas	nl-li-blo	nl,nl-li,nl-ven,nl-li-pee,nl-li-blo
Baexem	Leudal	nl-li-bxe	nl,nl-li,nl-omd,nl-wrt,nl-li-led,nl-li-bxe
Baneheide	Simpelveld	nl-li-sim	nl,nl-li,nl-hen,nl-li-sim
Banholt	Eijsden-Margraten	nl-li-eij	nl,nl-li,nl-mst,nl-li-eij
Beegden	Maasgouw	nl-li-bgd	nl,nl-li,nl-omd,nl-li-mgw,nl-li-bgd
Beek	Beek	nl-li-zak	nl,nl-li,nl-mst,nl-hen,nl-li-zak,nl-li-zak
Beesel	Beesel	nl-li-bsl	nl,nl-li,nl-omd,nl-li-bsl,nl-li-bsl
Belfeld	Venlo	nl-li-bfd	nl,nl-li,nl-ven,nl-li-ven,nl-li-bfd
Bemelen	Eijsden-Margraten	nl-li-eij	nl,nl-li,nl-mst,nl-li-eij
Berg en Terblijt	Valkenburg aan de Geul	nl-li-btt	nl,nl-li,nl-mst,nl-hen,nl-li-vlb,nl-li-btt
Bergen L	Bergen (L)	nl-li-brx	nl,nl-li,nl-nb,nl-vnr,nl-li-brx
Beringe	Peel en Maas	nl-li-bej	nl,nl-li,nl-nb,nl-ven,nl-omd,nl-li-pee,nl-li-bej
Beutenaken	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-mst,nl-hen,nl-li-gpn
Bingelrade	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-li-nth
Blitterswijck	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr
Bocholtz	Simpelveld	nl-li-sim	nl,nl-li,nl-hen,nl-li-sim
Born	Sittard-Geleen	nl-li-bon	nl,nl-li,nl-hen,nl-omd,nl-mst,nl-li-sig,nl-li-bon
Broekhuizen	Horst aan de Maas	nl-li-hsa	nl,nl-li,nl-ven,nl-vnr,nl-li-hsa
Broekhuizenvorst	Horst aan de Maas	nl-li-brh	nl,nl-li,nl-vnr,nl-ven,nl-li-hsa,nl-li-brh
Brunssum	Brunssum	nl-li-brn	nl,nl-li,nl-hen,nl-li-brn,nl-li-brn
Buchten	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-hen,nl-omd,nl-mst,nl-li-sig
Buggenum	Leudal	nl-li-bnu	nl,nl-li,nl-omd,nl-li-led,nl-li-bnu
Bunde	Meerssen	nl-li-bne	nl,nl-li,nl-mst,nl-li-mrn,nl-li-bne
Cadier en Keer	Eijsden-Margraten	nl-li-cdk	nl,nl-li,nl-mst,nl-li-eij,nl-li-cdk
Castenray	Venray	nl-li-csy	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-csy
Doenrade	Beekdaelen	nl-li-dre	nl,nl-li,nl-hen,nl-li-nth,nl-li-dre
Echt	Echt-Susteren	nl-li-ech	nl,nl-li,nl-omd,nl-li-esu,nl-li-ech
Eckelrade	Eijsden-Margraten	nl-li-eck	nl,nl-li,nl-mst,nl-li-eij,nl-li-eck
Egchel	Peel en Maas	nl-li-egl	nl,nl-li,nl-nb,nl-omd,nl-li-pee,nl-li-egl
Eijsden	Eijsden-Margraten	nl-li-eys	nl,nl-li,nl-mst,nl-li-eij,nl-li-eys
Einighausen	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-hen,nl-li-sig
Elkenrade	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-hen,nl-li-gpn
Ell	Leudal	nl-li-elx	nl,nl-li,nl-wrt,nl-omd,nl-li-led,nl-li-elx
Elsloo	Stein	nl-li-elo	nl,nl-li,nl-mst,nl-li-sti,nl-li-elo
Epen	Gulpen-Wittem	nl-li-epn	nl,nl-li,nl-hen,nl-li-gpn,nl-li-epn
Evertsoord	Horst aan de Maas	nl-li-hsa	nl,nl-li,nl-nb,nl-vnr,nl-ven,nl-li-hsa
Eygelshoven	Kerkrade	nl-li-eyl	nl,nl-li,nl-hen,nl-li-ker,nl-li-eyl
Eys	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-hen,nl-li-gpn
Geijsteren	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr
Geleen	Sittard-Geleen	nl-li-gee	nl,nl-li,nl-hen,nl-li-sig,nl-li-gee
Gennep	Gennep	nl-li-gen	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-vnr,nl-li-gen,nl-li-gen
Geulle	Meerssen	nl-li-gll	nl,nl-li,nl-mst,nl-li-mrn,nl-li-gll
Grashoek	Peel en Maas	nl-li-ghk	nl,nl-li,nl-nb,nl-ven,nl-li-pee,nl-li-ghk
Grathem	Leudal	nl-li-led	nl,nl-li,nl-omd,nl-wrt,nl-li-led
Grevenbicht	Sittard-Geleen	nl-li-gbc	nl,nl-li,nl-mst,nl-hen,nl-omd,nl-li-sig,nl-li-gbc
Griendtsveen	Horst aan de Maas	nl-li-hsa	nl,nl-li,nl-nb,nl-hlm,nl-vnr,nl-li-hsa
Gronsveld	Eijsden-Margraten	nl-li-eld	nl,nl-li,nl-mst,nl-li-eij,nl-li-eld
Grubbenvorst	Horst aan de Maas	nl-li-gbv	nl,nl-li,nl-ven,nl-li-hsa,nl-li-gbv
Gulpen	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-hen,nl-li-gpn,nl-li-gpn
Guttecoven	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-hen,nl-li-sig
Haelen	Leudal	nl-li-hae	nl,nl-li,nl-omd,nl-li-led,nl-li-hae
Haler	Leudal	nl-li-led	nl,nl-li,nl-wrt,nl-li-led
Heel	Maasgouw	nl-li-hee	nl,nl-li,nl-omd,nl-li-mgw,nl-li-hee
Heerlen	Heerlen	nl-li-hen	nl,nl-li,nl-hen,nl-li-hen,nl-li-hen
Hegelsom	Horst aan de Maas	nl-li-hsm	nl,nl-li,nl-nb,nl-vnr,nl-ven,nl-li-hsa,nl-li-hsm
Heibloem	Leudal	nl-li-led	nl,nl-li,nl-nb,nl-omd,nl-wrt,nl-li-led
Heide	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr
Heijen	Gennep	nl-li-hej	nl,nl-li,nl-nb,nl-vnr,nl-li-gen,nl-li-hej
Heijenrath	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-hen,nl-mst,nl-li-gpn
Helden	Peel en Maas	nl-li-hel	nl,nl-li,nl-nb,nl-ven,nl-omd,nl-li-pee,nl-li-hel
Herkenbosch	Roerdalen	nl-li-hrk	nl,nl-li,nl-omd,nl-li-roe,nl-li-hrk
Herten	Roermond	nl-li-zay	nl,nl-li,nl-omd,nl-li-omd,nl-li-zay
Heythuysen	Leudal	nl-li-hyy	nl,nl-li,nl-omd,nl-wrt,nl-li-led,nl-li-hyy
Hoensbroek	Heerlen	nl-li-hbr	nl,nl-li,nl-hen,nl-li-hen,nl-li-hbr
Holtum	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-omd,nl-hen,nl-li-sig
Horn	Leudal	nl-li-hox	nl,nl-li,nl-omd,nl-li-led,nl-li-hox
Horst	Horst aan de Maas	nl-li-hrs	nl,nl-li,nl-vnr,nl-ven,nl-li-hsa,nl-li-hrs
Hulsberg	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-mst,nl-li-nth
Hunsel	Leudal	nl-li-hun	nl,nl-li,nl-wrt,nl-omd,nl-li-led,nl-li-hun
Ingber	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-hen,nl-mst,nl-li-gpn
Ittervoort	Leudal	nl-li-itt	nl,nl-li,nl-omd,nl-wrt,nl-li-led,nl-li-itt
Jabeek	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-li-nth
Kelpen-Oler	Leudal	nl-li-led	nl,nl-li,nl-wrt,nl-omd,nl-li-led
Kerkrade	Kerkrade	nl-li-ker	nl,nl-li,nl-hen,nl-li-ker,nl-li-ker
Kessel	Peel en Maas	nl-li-ksl	nl,nl-li,nl-ven,nl-omd,nl-li-pee,nl-li-ksl
Klimmen	Voerendaal	nl-li-kln	nl,nl-li,nl-hen,nl-mst,nl-li-vdl,nl-li-kln
Koningsbosch	Echt-Susteren	nl-li-esu	nl,nl-li,nl-omd,nl-li-esu
Koningslust	Peel en Maas	nl-li-kgt	nl,nl-li,nl-nb,nl-ven,nl-li-pee,nl-li-kgt
Kronenberg	Horst aan de Maas	nl-li-kng	nl,nl-li,nl-nb,nl-vnr,nl-ven,nl-li-hsa,nl-li-kng
Landgraaf	Landgraaf	nl-li-laf	nl,nl-li,nl-hen,nl-li-laf,nl-li-laf
Lemiers	Vaals	nl-li-vls	nl,nl-li,nl-hen,nl-li-vls
Leunen	Venray	nl-li-lnn	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-lnn
Leveroy	Nederweert	nl-li-nrw	nl,nl-li,nl-wrt,nl-omd,nl-li-nrw
Limbricht	Sittard-Geleen	nl-li-lim	nl,nl-li,nl-hen,nl-li-sig,nl-li-lim
Linne	Maasgouw	nl-li-lin	nl,nl-li,nl-omd,nl-li-mgw,nl-li-lin
Lomm	Venlo	nl-li-lom	nl,nl-li,nl-ven,nl-li-ven,nl-li-lom
Lottum	Horst aan de Maas	nl-li-ltm	nl,nl-li,nl-ven,nl-li-hsa,nl-li-ltm
Maasbracht	Maasgouw	nl-li-msb	nl,nl-li,nl-omd,nl-li-mgw,nl-li-msb
Maasbree	Peel en Maas	nl-li-zbc	nl,nl-li,nl-nb,nl-ven,nl-li-pee,nl-li-zbc
Maastricht	Maastricht	nl-li-mst	nl,nl-li,nl-mst,nl-li-mst,nl-li-mst
Maastricht-Airport	Beek	nl-li-zak	nl,nl-li,nl-mst,nl-li-zak
Margraten	Eijsden-Margraten	nl-li-zbf	nl,nl-li,nl-mst,nl-hen,nl-li-eij,nl-li-zbf
Maria Hoop	Echt-Susteren	nl-li-esu	nl,nl-li,nl-omd,nl-li-esu
Mechelen	Gulpen-Wittem	nl-li-mec	nl,nl-li,nl-hen,nl-li-gpn,nl-li-mec
Meerlo	Horst aan de Maas	nl-li-hsa	nl,nl-li,nl-nb,nl-vnr,nl-li-hsa
Meerssen	Meerssen	nl-li-mrn	nl,nl-li,nl-mst,nl-li-mrn,nl-li-mrn
Meijel	Peel en Maas	nl-li-mej	nl,nl-li,nl-nb,nl-wrt,nl-li-pee,nl-li-mej
Melderslo	Horst aan de Maas	nl-li-mdo	nl,nl-li,nl-vnr,nl-ven,nl-li-hsa,nl-li-mdo
Melick	Roerdalen	nl-li-mck	nl,nl-li,nl-omd,nl-li-roe,nl-li-mck
Merkelbeek	Beekdaelen	nl-li-meb	nl,nl-li,nl-hen,nl-li-nth,nl-li-meb
Merselo	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr
Meterik	Horst aan de Maas	nl-li-mtk	nl,nl-li,nl-vnr,nl-ven,nl-li-hsa,nl-li-mtk
Mheer	Eijsden-Margraten	nl-li-eij	nl,nl-li,nl-mst,nl-li-eij
Middelaar	Mook en Middelaar	nl-li-mla	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-li-mok,nl-li-mla
Milsbeek	Gennep	nl-li-mbk	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-li-gen,nl-li-mbk
Molenhoek	Mook en Middelaar	nl-li-mol	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-li-mok,nl-li-mol
Montfort	Roerdalen	nl-li-roe	nl,nl-li,nl-omd,nl-li-roe
Mook	Mook en Middelaar	nl-li-mok	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-li-mok,nl-li-mok
Moorveld	Meerssen	nl-li-mrn	nl,nl-li,nl-mst,nl-li-mrn
Munstergeleen	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-hen,nl-li-sig
Nederweert	Nederweert	nl-li-nrw	nl,nl-li,nl-nb,nl-wrt,nl-li-nrw,nl-li-nrw
Nederweert-Eind	Nederweert	nl-li-nrw	nl,nl-li,nl-wrt,nl-li-nrw
Neer	Leudal	nl-li-ner	nl,nl-li,nl-omd,nl-li-led,nl-li-ner
Neeritter	Leudal	nl-li-eer	nl,nl-li,nl-wrt,nl-omd,nl-li-led,nl-li-eer
Nieuwstadt	Echt-Susteren	nl-li-nws	nl,nl-li,nl-hen,nl-omd,nl-li-esu,nl-li-nws
Noorbeek	Eijsden-Margraten	nl-li-eij	nl,nl-li,nl-mst,nl-li-eij
Nunhem	Leudal	nl-li-nnm	nl,nl-li,nl-omd,nl-li-led,nl-li-nnm
Nuth	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-li-nth,nl-li-nth
Obbicht	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-mst,nl-hen,nl-li-sig
Ohé en Laak	Maasgouw	nl-li-oel	nl,nl-li,nl-omd,nl-li-mgw,nl-li-oel
Oirlo	Venray	nl-li-oil	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-oil
Oirsbeek	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-li-nth
Oostrum	Venray	nl-li-otr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-otr
Oostrum	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr
Ospel	Nederweert	nl-li-osp	nl,nl-li,nl-nb,nl-wrt,nl-li-nrw,nl-li-osp
Ottersum	Gennep	nl-li-gen	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-vnr,nl-li-gen
Panningen	Peel en Maas	nl-li-pan	nl,nl-li,nl-nb,nl-ven,nl-omd,nl-li-pee,nl-li-pan
Papenhoven	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-hen,nl-mst,nl-omd,nl-li-sig
Plasmolen	Mook en Middelaar	nl-li-mok	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-li-mok
Posterholt	Roerdalen	nl-li-roe	nl,nl-li,nl-omd,nl-li-roe
Puth	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-li-nth
Ransdaal	Voerendaal	nl-li-vdl	nl,nl-li,nl-hen,nl-li-vdl
Reijmerstok	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-mst,nl-hen,nl-li-gpn
Reuver	Beesel	nl-li-reu	nl,nl-li,nl-ven,nl-omd,nl-li-bsl,nl-li-reu
Roermond	Roermond	nl-li-omd	nl,nl-li,nl-omd,nl-li-omd,nl-li-omd
Roggel	Leudal	nl-li-rog	nl,nl-li,nl-omd,nl-li-led,nl-li-rog
Roosteren	Echt-Susteren	nl-li-rst	nl,nl-li,nl-omd,nl-li-esu,nl-li-rst
Scheulder	Eijsden-Margraten	nl-li-eij	nl,nl-li,nl-mst,nl-hen,nl-li-eij
Schimmert	Beekdaelen	nl-li-scm	nl,nl-li,nl-hen,nl-mst,nl-li-nth,nl-li-scm
Schin op Geul	Valkenburg aan de Geul	nl-li-sog	nl,nl-li,nl-hen,nl-mst,nl-li-vlb,nl-li-sog
Schinnen	Beekdaelen	nl-li-scn	nl,nl-li,nl-hen,nl-li-nth,nl-li-scn
Schinveld	Beekdaelen	nl-li-svd	nl,nl-li,nl-hen,nl-li-nth,nl-li-svd
Sevenum	Horst aan de Maas	nl-li-svm	nl,nl-li,nl-nb,nl-ven,nl-vnr,nl-li-hsa,nl-li-svm
Siebengewald	Bergen (L)	nl-li-brx	nl,nl-li,nl-nb,nl-vnr,nl-li-brx
Simpelveld	Simpelveld	nl-li-sim	nl,nl-li,nl-hen,nl-li-sim,nl-li-sim
Sint Geertruid	Eijsden-Margraten	nl-li-eij	nl,nl-li,nl-mst,nl-li-eij
Sint Joost	Echt-Susteren	nl-li-esu	nl,nl-li,nl-omd,nl-li-esu
Sint Odiliënberg	Roerdalen	nl-li-sob	nl,nl-li,nl-omd,nl-li-roe,nl-li-sob
Sittard	Sittard-Geleen	nl-li-sit	nl,nl-li,nl-hen,nl-li-sig,nl-li-sit
Slenaken	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-mst,nl-hen,nl-li-gpn
Smakt	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr
Spaubeek	Beek	nl-li-spa	nl,nl-li,nl-hen,nl-li-zak,nl-li-spa
Stein	Stein	nl-li-sti	nl,nl-li,nl-mst,nl-li-sti,nl-li-sti
Stevensweert	Maasgouw	nl-li-svw	nl,nl-li,nl-omd,nl-li-mgw,nl-li-svw
Steyl	Venlo	nl-li-ven	nl,nl-li,nl-ven,nl-li-ven
Stramproy	Weert	nl-li-stp	nl,nl-li,nl-wrt,nl-li-wrt,nl-li-stp
Susteren	Echt-Susteren	nl-li-zaj	nl,nl-li,nl-omd,nl-li-esu,nl-li-zaj
Swalmen	Roermond	nl-li-swm	nl,nl-li,nl-omd,nl-li-omd,nl-li-swm
Sweikhuizen	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-li-nth
Swolgen	Horst aan de Maas	nl-li-hsa	nl,nl-li,nl-vnr,nl-li-hsa
Tegelen	Venlo	nl-li-teg	nl,nl-li,nl-ven,nl-li-ven,nl-li-teg
Thorn	Maasgouw	nl-li-thn	nl,nl-li,nl-omd,nl-wrt,nl-li-mgw,nl-li-thn
Tienray	Horst aan de Maas	nl-li-tny	nl,nl-li,nl-nb,nl-vnr,nl-li-hsa,nl-li-tny
Ulestraten	Meerssen	nl-li-uls	nl,nl-li,nl-mst,nl-hen,nl-li-mrn,nl-li-uls
Urmond	Stein	nl-li-umo	nl,nl-li,nl-mst,nl-li-sti,nl-li-umo
Vaals	Vaals	nl-li-vls	nl,nl-li,nl-hen,nl-li-vls,nl-li-vls
Valkenburg	Valkenburg aan de Geul	nl-li-vlb	nl,nl-li,nl-mst,nl-hen,nl-li-vlb,nl-li-vlb
Velden	Venlo	nl-li-ved	nl,nl-li,nl-ven,nl-li-ven,nl-li-ved
Ven-Zelderheide	Gennep	nl-li-vzh	nl,nl-li,nl-nb,nl-ge,nl-nij,nl-li-gen,nl-li-vzh
Venlo	Venlo	nl-li-ven	nl,nl-li,nl-ven,nl-li-ven,nl-li-ven
Venray	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-vnr
Veulen	Venray	nl-li-vln	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-vln
Vijlen	Vaals	nl-li-vls	nl,nl-li,nl-hen,nl-li-vls
Vlodrop	Roerdalen	nl-li-vld	nl,nl-li,nl-omd,nl-li-roe,nl-li-vld
Voerendaal	Voerendaal	nl-li-vdl	nl,nl-li,nl-hen,nl-li-vdl,nl-li-vdl
Vredepeel	Venray	nl-li-vpl	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-vpl
Walem	Valkenburg aan de Geul	nl-li-vlb	nl,nl-li,nl-hen,nl-mst,nl-li-vlb
Wanssum	Venray	nl-li-was	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr,nl-li-was
Weert	Weert	nl-li-wrt	nl,nl-li,nl-nb,nl-wrt,nl-li-wrt,nl-li-wrt
Well L	Bergen (L)	nl-li-brx	nl,nl-li,nl-nb,nl-vnr,nl-li-brx
Wellerlooi	Bergen (L)	nl-li-wll	nl,nl-li,nl-nb,nl-vnr,nl-li-brx,nl-li-wll
Wessem	Maasgouw	nl-li-wsm	nl,nl-li,nl-omd,nl-li-mgw,nl-li-wsm
Wijlre	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-hen,nl-li-gpn
Wijnandsrade	Beekdaelen	nl-li-nth	nl,nl-li,nl-hen,nl-li-nth
Windraak	Sittard-Geleen	nl-li-sig	nl,nl-li,nl-hen,nl-li-sig
Wittem	Gulpen-Wittem	nl-li-gpn	nl,nl-li,nl-hen,nl-li-gpn
Ysselsteyn	Venray	nl-li-vnr	nl,nl-li,nl-nb,nl-vnr,nl-li-vnr
""";
