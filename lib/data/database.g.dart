// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(StringExpressionOperators(name).trim().length)
            .isBetweenValues(1, 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Cadence, String> cadence =
      GeneratedColumn<String>(
        'cadence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Cadence>($RecurringRulesTable.$convertercadence);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> anchorDate =
      GeneratedColumn<String>(
        'anchor_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RecurringRulesTable.$converteranchorDate);
  static const VerificationMeta _nextIndexMeta = const VerificationMeta(
    'nextIndex',
  );
  @override
  late final GeneratedColumn<int> nextIndex = GeneratedColumn<int>(
    'next_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MissionBonus, String> bonus =
      GeneratedColumn<String>(
        'bonus',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MissionBonus>($RecurringRulesTable.$converterbonus);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> lastPostedOn =
      GeneratedColumn<String>(
        'last_posted_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RecurringRulesTable.$converterlastPostedOnn);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cadence,
    anchorDate,
    nextIndex,
    bonus,
    lastPostedOn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('next_index')) {
      context.handle(
        _nextIndexMeta,
        nextIndex.isAcceptableOrUnknown(data['next_index']!, _nextIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cadence: $RecurringRulesTable.$convertercadence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cadence'],
        )!,
      ),
      anchorDate: $RecurringRulesTable.$converteranchorDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}anchor_date'],
        )!,
      ),
      nextIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_index'],
      )!,
      bonus: $RecurringRulesTable.$converterbonus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}bonus'],
        )!,
      ),
      lastPostedOn: $RecurringRulesTable.$converterlastPostedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_posted_on'],
        ),
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Cadence, String, String> $convertercadence =
      const EnumNameConverter<Cadence>(Cadence.values);
  static TypeConverter<DateTime, String> $converteranchorDate =
      const DateOnlyConverter();
  static JsonTypeConverter2<MissionBonus, String, String> $converterbonus =
      const EnumNameConverter<MissionBonus>(MissionBonus.values);
  static TypeConverter<DateTime, String> $converterlastPostedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterlastPostedOnn =
      NullAwareTypeConverter.wrap($converterlastPostedOn);
}

class RecurringRuleRow extends DataClass
    implements Insertable<RecurringRuleRow> {
  final int id;
  final String name;
  final Cadence cadence;
  final DateTime anchorDate;
  final int nextIndex;
  final MissionBonus bonus;
  final DateTime? lastPostedOn;
  final DateTime createdAt;
  const RecurringRuleRow({
    required this.id,
    required this.name,
    required this.cadence,
    required this.anchorDate,
    required this.nextIndex,
    required this.bonus,
    this.lastPostedOn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['cadence'] = Variable<String>(
        $RecurringRulesTable.$convertercadence.toSql(cadence),
      );
    }
    {
      map['anchor_date'] = Variable<String>(
        $RecurringRulesTable.$converteranchorDate.toSql(anchorDate),
      );
    }
    map['next_index'] = Variable<int>(nextIndex);
    {
      map['bonus'] = Variable<String>(
        $RecurringRulesTable.$converterbonus.toSql(bonus),
      );
    }
    if (!nullToAbsent || lastPostedOn != null) {
      map['last_posted_on'] = Variable<String>(
        $RecurringRulesTable.$converterlastPostedOnn.toSql(lastPostedOn),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      name: Value(name),
      cadence: Value(cadence),
      anchorDate: Value(anchorDate),
      nextIndex: Value(nextIndex),
      bonus: Value(bonus),
      lastPostedOn: lastPostedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPostedOn),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRuleRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cadence: $RecurringRulesTable.$convertercadence.fromJson(
        serializer.fromJson<String>(json['cadence']),
      ),
      anchorDate: serializer.fromJson<DateTime>(json['anchorDate']),
      nextIndex: serializer.fromJson<int>(json['nextIndex']),
      bonus: $RecurringRulesTable.$converterbonus.fromJson(
        serializer.fromJson<String>(json['bonus']),
      ),
      lastPostedOn: serializer.fromJson<DateTime?>(json['lastPostedOn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cadence': serializer.toJson<String>(
        $RecurringRulesTable.$convertercadence.toJson(cadence),
      ),
      'anchorDate': serializer.toJson<DateTime>(anchorDate),
      'nextIndex': serializer.toJson<int>(nextIndex),
      'bonus': serializer.toJson<String>(
        $RecurringRulesTable.$converterbonus.toJson(bonus),
      ),
      'lastPostedOn': serializer.toJson<DateTime?>(lastPostedOn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringRuleRow copyWith({
    int? id,
    String? name,
    Cadence? cadence,
    DateTime? anchorDate,
    int? nextIndex,
    MissionBonus? bonus,
    Value<DateTime?> lastPostedOn = const Value.absent(),
    DateTime? createdAt,
  }) => RecurringRuleRow(
    id: id ?? this.id,
    name: name ?? this.name,
    cadence: cadence ?? this.cadence,
    anchorDate: anchorDate ?? this.anchorDate,
    nextIndex: nextIndex ?? this.nextIndex,
    bonus: bonus ?? this.bonus,
    lastPostedOn: lastPostedOn.present ? lastPostedOn.value : this.lastPostedOn,
    createdAt: createdAt ?? this.createdAt,
  );
  RecurringRuleRow copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRuleRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      nextIndex: data.nextIndex.present ? data.nextIndex.value : this.nextIndex,
      bonus: data.bonus.present ? data.bonus.value : this.bonus,
      lastPostedOn: data.lastPostedOn.present
          ? data.lastPostedOn.value
          : this.lastPostedOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRuleRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cadence: $cadence, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('nextIndex: $nextIndex, ')
          ..write('bonus: $bonus, ')
          ..write('lastPostedOn: $lastPostedOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    cadence,
    anchorDate,
    nextIndex,
    bonus,
    lastPostedOn,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRuleRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.cadence == this.cadence &&
          other.anchorDate == this.anchorDate &&
          other.nextIndex == this.nextIndex &&
          other.bonus == this.bonus &&
          other.lastPostedOn == this.lastPostedOn &&
          other.createdAt == this.createdAt);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRuleRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<Cadence> cadence;
  final Value<DateTime> anchorDate;
  final Value<int> nextIndex;
  final Value<MissionBonus> bonus;
  final Value<DateTime?> lastPostedOn;
  final Value<DateTime> createdAt;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cadence = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.nextIndex = const Value.absent(),
    this.bonus = const Value.absent(),
    this.lastPostedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Cadence cadence,
    required DateTime anchorDate,
    this.nextIndex = const Value.absent(),
    required MissionBonus bonus,
    this.lastPostedOn = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       cadence = Value(cadence),
       anchorDate = Value(anchorDate),
       bonus = Value(bonus),
       createdAt = Value(createdAt);
  static Insertable<RecurringRuleRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? cadence,
    Expression<String>? anchorDate,
    Expression<int>? nextIndex,
    Expression<String>? bonus,
    Expression<String>? lastPostedOn,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cadence != null) 'cadence': cadence,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (nextIndex != null) 'next_index': nextIndex,
      if (bonus != null) 'bonus': bonus,
      if (lastPostedOn != null) 'last_posted_on': lastPostedOn,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<Cadence>? cadence,
    Value<DateTime>? anchorDate,
    Value<int>? nextIndex,
    Value<MissionBonus>? bonus,
    Value<DateTime?>? lastPostedOn,
    Value<DateTime>? createdAt,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cadence: cadence ?? this.cadence,
      anchorDate: anchorDate ?? this.anchorDate,
      nextIndex: nextIndex ?? this.nextIndex,
      bonus: bonus ?? this.bonus,
      lastPostedOn: lastPostedOn ?? this.lastPostedOn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<String>(
        $RecurringRulesTable.$convertercadence.toSql(cadence.value),
      );
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<String>(
        $RecurringRulesTable.$converteranchorDate.toSql(anchorDate.value),
      );
    }
    if (nextIndex.present) {
      map['next_index'] = Variable<int>(nextIndex.value);
    }
    if (bonus.present) {
      map['bonus'] = Variable<String>(
        $RecurringRulesTable.$converterbonus.toSql(bonus.value),
      );
    }
    if (lastPostedOn.present) {
      map['last_posted_on'] = Variable<String>(
        $RecurringRulesTable.$converterlastPostedOnn.toSql(lastPostedOn.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cadence: $cadence, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('nextIndex: $nextIndex, ')
          ..write('bonus: $bonus, ')
          ..write('lastPostedOn: $lastPostedOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MissionsTable extends Missions
    with TableInfo<$MissionsTable, MissionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(StringExpressionOperators(name).trim().length)
            .isBetweenValues(1, 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MissionBonus, String> bonus =
      GeneratedColumn<String>(
        'bonus',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MissionBonus>($MissionsTable.$converterbonus);
  @override
  late final GeneratedColumnWithTypeConverter<MissionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('open'),
      ).withConverter<MissionStatus>($MissionsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awardedBonusMeta = const VerificationMeta(
    'awardedBonus',
  );
  @override
  late final GeneratedColumn<int> awardedBonus = GeneratedColumn<int>(
    'awarded_bonus',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_rules (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    bonus,
    status,
    createdAt,
    completedAt,
    awardedBonus,
    ruleId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'missions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MissionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('awarded_bonus')) {
      context.handle(
        _awardedBonusMeta,
        awardedBonus.isAcceptableOrUnknown(
          data['awarded_bonus']!,
          _awardedBonusMeta,
        ),
      );
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MissionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MissionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bonus: $MissionsTable.$converterbonus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}bonus'],
        )!,
      ),
      status: $MissionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      awardedBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awarded_bonus'],
      ),
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      ),
    );
  }

  @override
  $MissionsTable createAlias(String alias) {
    return $MissionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MissionBonus, String, String> $converterbonus =
      const EnumNameConverter<MissionBonus>(MissionBonus.values);
  static JsonTypeConverter2<MissionStatus, String, String> $converterstatus =
      const EnumNameConverter<MissionStatus>(MissionStatus.values);
}

class MissionRow extends DataClass implements Insertable<MissionRow> {
  final int id;
  final String name;
  final MissionBonus bonus;
  final MissionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? awardedBonus;
  final int? ruleId;
  const MissionRow({
    required this.id,
    required this.name,
    required this.bonus,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.awardedBonus,
    this.ruleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['bonus'] = Variable<String>(
        $MissionsTable.$converterbonus.toSql(bonus),
      );
    }
    {
      map['status'] = Variable<String>(
        $MissionsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || awardedBonus != null) {
      map['awarded_bonus'] = Variable<int>(awardedBonus);
    }
    if (!nullToAbsent || ruleId != null) {
      map['rule_id'] = Variable<int>(ruleId);
    }
    return map;
  }

  MissionsCompanion toCompanion(bool nullToAbsent) {
    return MissionsCompanion(
      id: Value(id),
      name: Value(name),
      bonus: Value(bonus),
      status: Value(status),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      awardedBonus: awardedBonus == null && nullToAbsent
          ? const Value.absent()
          : Value(awardedBonus),
      ruleId: ruleId == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleId),
    );
  }

  factory MissionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MissionRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bonus: $MissionsTable.$converterbonus.fromJson(
        serializer.fromJson<String>(json['bonus']),
      ),
      status: $MissionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      awardedBonus: serializer.fromJson<int?>(json['awardedBonus']),
      ruleId: serializer.fromJson<int?>(json['ruleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'bonus': serializer.toJson<String>(
        $MissionsTable.$converterbonus.toJson(bonus),
      ),
      'status': serializer.toJson<String>(
        $MissionsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'awardedBonus': serializer.toJson<int?>(awardedBonus),
      'ruleId': serializer.toJson<int?>(ruleId),
    };
  }

  MissionRow copyWith({
    int? id,
    String? name,
    MissionBonus? bonus,
    MissionStatus? status,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> awardedBonus = const Value.absent(),
    Value<int?> ruleId = const Value.absent(),
  }) => MissionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    bonus: bonus ?? this.bonus,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    awardedBonus: awardedBonus.present ? awardedBonus.value : this.awardedBonus,
    ruleId: ruleId.present ? ruleId.value : this.ruleId,
  );
  MissionRow copyWithCompanion(MissionsCompanion data) {
    return MissionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bonus: data.bonus.present ? data.bonus.value : this.bonus,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      awardedBonus: data.awardedBonus.present
          ? data.awardedBonus.value
          : this.awardedBonus,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MissionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bonus: $bonus, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedBonus: $awardedBonus, ')
          ..write('ruleId: $ruleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    bonus,
    status,
    createdAt,
    completedAt,
    awardedBonus,
    ruleId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.bonus == this.bonus &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.awardedBonus == this.awardedBonus &&
          other.ruleId == this.ruleId);
}

class MissionsCompanion extends UpdateCompanion<MissionRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<MissionBonus> bonus;
  final Value<MissionStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int?> awardedBonus;
  final Value<int?> ruleId;
  const MissionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bonus = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.awardedBonus = const Value.absent(),
    this.ruleId = const Value.absent(),
  });
  MissionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required MissionBonus bonus,
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.awardedBonus = const Value.absent(),
    this.ruleId = const Value.absent(),
  }) : name = Value(name),
       bonus = Value(bonus),
       createdAt = Value(createdAt);
  static Insertable<MissionRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? bonus,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? awardedBonus,
    Expression<int>? ruleId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bonus != null) 'bonus': bonus,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (awardedBonus != null) 'awarded_bonus': awardedBonus,
      if (ruleId != null) 'rule_id': ruleId,
    });
  }

  MissionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<MissionBonus>? bonus,
    Value<MissionStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int?>? awardedBonus,
    Value<int?>? ruleId,
  }) {
    return MissionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bonus: bonus ?? this.bonus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      awardedBonus: awardedBonus ?? this.awardedBonus,
      ruleId: ruleId ?? this.ruleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bonus.present) {
      map['bonus'] = Variable<String>(
        $MissionsTable.$converterbonus.toSql(bonus.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $MissionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (awardedBonus.present) {
      map['awarded_bonus'] = Variable<int>(awardedBonus.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bonus: $bonus, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedBonus: $awardedBonus, ')
          ..write('ruleId: $ruleId')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, QuestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(StringExpressionOperators(name).trim().length)
            .isBetweenValues(1, 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    check: () => ComparableExpr(note.length).isSmallerOrEqualValue(500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Difficulty, String> difficulty =
      GeneratedColumn<String>(
        'difficulty',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Difficulty>($QuestsTable.$converterdifficulty);
  static const VerificationMeta _missionIdMeta = const VerificationMeta(
    'missionId',
  );
  @override
  late final GeneratedColumn<int> missionId = GeneratedColumn<int>(
    'mission_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES missions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awardedXpMeta = const VerificationMeta(
    'awardedXp',
  );
  @override
  late final GeneratedColumn<int> awardedXp = GeneratedColumn<int>(
    'awarded_xp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    note,
    difficulty,
    missionId,
    sortOrder,
    createdAt,
    completedAt,
    awardedXp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('mission_id')) {
      context.handle(
        _missionIdMeta,
        missionId.isAcceptableOrUnknown(data['mission_id']!, _missionIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('awarded_xp')) {
      context.handle(
        _awardedXpMeta,
        awardedXp.isAcceptableOrUnknown(data['awarded_xp']!, _awardedXpMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      difficulty: $QuestsTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      missionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mission_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      awardedXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awarded_xp'],
      ),
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Difficulty, String, String> $converterdifficulty =
      const EnumNameConverter<Difficulty>(Difficulty.values);
}

class QuestRow extends DataClass implements Insertable<QuestRow> {
  final int id;
  final String name;
  final String? note;
  final Difficulty difficulty;
  final int? missionId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? awardedXp;
  const QuestRow({
    required this.id,
    required this.name,
    this.note,
    required this.difficulty,
    this.missionId,
    required this.sortOrder,
    required this.createdAt,
    this.completedAt,
    this.awardedXp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['difficulty'] = Variable<String>(
        $QuestsTable.$converterdifficulty.toSql(difficulty),
      );
    }
    if (!nullToAbsent || missionId != null) {
      map['mission_id'] = Variable<int>(missionId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || awardedXp != null) {
      map['awarded_xp'] = Variable<int>(awardedXp);
    }
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      difficulty: Value(difficulty),
      missionId: missionId == null && nullToAbsent
          ? const Value.absent()
          : Value(missionId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      awardedXp: awardedXp == null && nullToAbsent
          ? const Value.absent()
          : Value(awardedXp),
    );
  }

  factory QuestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      difficulty: $QuestsTable.$converterdifficulty.fromJson(
        serializer.fromJson<String>(json['difficulty']),
      ),
      missionId: serializer.fromJson<int?>(json['missionId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      awardedXp: serializer.fromJson<int?>(json['awardedXp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
      'difficulty': serializer.toJson<String>(
        $QuestsTable.$converterdifficulty.toJson(difficulty),
      ),
      'missionId': serializer.toJson<int?>(missionId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'awardedXp': serializer.toJson<int?>(awardedXp),
    };
  }

  QuestRow copyWith({
    int? id,
    String? name,
    Value<String?> note = const Value.absent(),
    Difficulty? difficulty,
    Value<int?> missionId = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> awardedXp = const Value.absent(),
  }) => QuestRow(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
    difficulty: difficulty ?? this.difficulty,
    missionId: missionId.present ? missionId.value : this.missionId,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    awardedXp: awardedXp.present ? awardedXp.value : this.awardedXp,
  );
  QuestRow copyWithCompanion(QuestsCompanion data) {
    return QuestRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      missionId: data.missionId.present ? data.missionId.value : this.missionId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      awardedXp: data.awardedXp.present ? data.awardedXp.value : this.awardedXp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('difficulty: $difficulty, ')
          ..write('missionId: $missionId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedXp: $awardedXp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    note,
    difficulty,
    missionId,
    sortOrder,
    createdAt,
    completedAt,
    awardedXp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.difficulty == this.difficulty &&
          other.missionId == this.missionId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.awardedXp == this.awardedXp);
}

class QuestsCompanion extends UpdateCompanion<QuestRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> note;
  final Value<Difficulty> difficulty;
  final Value<int?> missionId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int?> awardedXp;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.missionId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.awardedXp = const Value.absent(),
  });
  QuestsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
    required Difficulty difficulty,
    this.missionId = const Value.absent(),
    required int sortOrder,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.awardedXp = const Value.absent(),
  }) : name = Value(name),
       difficulty = Value(difficulty),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<QuestRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<String>? difficulty,
    Expression<int>? missionId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? awardedXp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (difficulty != null) 'difficulty': difficulty,
      if (missionId != null) 'mission_id': missionId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (awardedXp != null) 'awarded_xp': awardedXp,
    });
  }

  QuestsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? note,
    Value<Difficulty>? difficulty,
    Value<int?>? missionId,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int?>? awardedXp,
  }) {
    return QuestsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      difficulty: difficulty ?? this.difficulty,
      missionId: missionId ?? this.missionId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      awardedXp: awardedXp ?? this.awardedXp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(
        $QuestsTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (missionId.present) {
      map['mission_id'] = Variable<int>(missionId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (awardedXp.present) {
      map['awarded_xp'] = Variable<int>(awardedXp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('difficulty: $difficulty, ')
          ..write('missionId: $missionId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedXp: $awardedXp')
          ..write(')'))
        .toString();
  }
}

class $RuleQuestsTable extends RuleQuests
    with TableInfo<$RuleQuestsTable, RuleQuestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleQuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_rules (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Difficulty, String> difficulty =
      GeneratedColumn<String>(
        'difficulty',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Difficulty>($RuleQuestsTable.$converterdifficulty);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleId,
    name,
    difficulty,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<RuleQuestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleQuestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleQuestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      difficulty: $RuleQuestsTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $RuleQuestsTable createAlias(String alias) {
    return $RuleQuestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Difficulty, String, String> $converterdifficulty =
      const EnumNameConverter<Difficulty>(Difficulty.values);
}

class RuleQuestRow extends DataClass implements Insertable<RuleQuestRow> {
  final int id;
  final int ruleId;
  final String name;
  final Difficulty difficulty;
  final int sortOrder;
  const RuleQuestRow({
    required this.id,
    required this.ruleId,
    required this.name,
    required this.difficulty,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rule_id'] = Variable<int>(ruleId);
    map['name'] = Variable<String>(name);
    {
      map['difficulty'] = Variable<String>(
        $RuleQuestsTable.$converterdifficulty.toSql(difficulty),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  RuleQuestsCompanion toCompanion(bool nullToAbsent) {
    return RuleQuestsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      name: Value(name),
      difficulty: Value(difficulty),
      sortOrder: Value(sortOrder),
    );
  }

  factory RuleQuestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleQuestRow(
      id: serializer.fromJson<int>(json['id']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      name: serializer.fromJson<String>(json['name']),
      difficulty: $RuleQuestsTable.$converterdifficulty.fromJson(
        serializer.fromJson<String>(json['difficulty']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ruleId': serializer.toJson<int>(ruleId),
      'name': serializer.toJson<String>(name),
      'difficulty': serializer.toJson<String>(
        $RuleQuestsTable.$converterdifficulty.toJson(difficulty),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  RuleQuestRow copyWith({
    int? id,
    int? ruleId,
    String? name,
    Difficulty? difficulty,
    int? sortOrder,
  }) => RuleQuestRow(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    name: name ?? this.name,
    difficulty: difficulty ?? this.difficulty,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  RuleQuestRow copyWithCompanion(RuleQuestsCompanion data) {
    return RuleQuestRow(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      name: data.name.present ? data.name.value : this.name,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleQuestRow(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('name: $name, ')
          ..write('difficulty: $difficulty, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ruleId, name, difficulty, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleQuestRow &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.name == this.name &&
          other.difficulty == this.difficulty &&
          other.sortOrder == this.sortOrder);
}

class RuleQuestsCompanion extends UpdateCompanion<RuleQuestRow> {
  final Value<int> id;
  final Value<int> ruleId;
  final Value<String> name;
  final Value<Difficulty> difficulty;
  final Value<int> sortOrder;
  const RuleQuestsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.name = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  RuleQuestsCompanion.insert({
    this.id = const Value.absent(),
    required int ruleId,
    required String name,
    required Difficulty difficulty,
    required int sortOrder,
  }) : ruleId = Value(ruleId),
       name = Value(name),
       difficulty = Value(difficulty),
       sortOrder = Value(sortOrder);
  static Insertable<RuleQuestRow> custom({
    Expression<int>? id,
    Expression<int>? ruleId,
    Expression<String>? name,
    Expression<String>? difficulty,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (name != null) 'name': name,
      if (difficulty != null) 'difficulty': difficulty,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  RuleQuestsCompanion copyWith({
    Value<int>? id,
    Value<int>? ruleId,
    Value<String>? name,
    Value<Difficulty>? difficulty,
    Value<int>? sortOrder,
  }) {
    return RuleQuestsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(
        $RuleQuestsTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleQuestsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('name: $name, ')
          ..write('difficulty: $difficulty, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $AppStateTable extends AppState
    with TableInfo<$AppStateTable, AppStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    check: () => ComparableExpr(totalXp).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heroNameMeta = const VerificationMeta(
    'heroName',
  );
  @override
  late final GeneratedColumn<String> heroName = GeneratedColumn<String>(
    'hero_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppLanguage, String> language =
      GeneratedColumn<String>(
        'language',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('system'),
      ).withConverter<AppLanguage>($AppStateTable.$converterlanguage);
  @override
  late final GeneratedColumnWithTypeConverter<AppTheme, String> theme =
      GeneratedColumn<String>(
        'theme',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('system'),
      ).withConverter<AppTheme>($AppStateTable.$convertertheme);
  @override
  late final GeneratedColumnWithTypeConverter<DisplayFont, String> displayFont =
      GeneratedColumn<String>(
        'display_font',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('figtree'),
      ).withConverter<DisplayFont>($AppStateTable.$converterdisplayFont);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    totalXp,
    heroName,
    language,
    theme,
    displayFont,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('hero_name')) {
      context.handle(
        _heroNameMeta,
        heroName.isAcceptableOrUnknown(data['hero_name']!, _heroNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      heroName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_name'],
      )!,
      language: $AppStateTable.$converterlanguage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}language'],
        )!,
      ),
      theme: $AppStateTable.$convertertheme.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme'],
        )!,
      ),
      displayFont: $AppStateTable.$converterdisplayFont.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}display_font'],
        )!,
      ),
    );
  }

  @override
  $AppStateTable createAlias(String alias) {
    return $AppStateTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppLanguage, String, String> $converterlanguage =
      const EnumNameConverter<AppLanguage>(AppLanguage.values);
  static JsonTypeConverter2<AppTheme, String, String> $convertertheme =
      const EnumNameConverter<AppTheme>(AppTheme.values);
  static JsonTypeConverter2<DisplayFont, String, String> $converterdisplayFont =
      const EnumNameConverter<DisplayFont>(DisplayFont.values);
}

class AppStateRow extends DataClass implements Insertable<AppStateRow> {
  final int id;
  final int totalXp;
  final String heroName;
  final AppLanguage language;
  final AppTheme theme;
  final DisplayFont displayFont;
  const AppStateRow({
    required this.id,
    required this.totalXp,
    required this.heroName,
    required this.language,
    required this.theme,
    required this.displayFont,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_xp'] = Variable<int>(totalXp);
    map['hero_name'] = Variable<String>(heroName);
    {
      map['language'] = Variable<String>(
        $AppStateTable.$converterlanguage.toSql(language),
      );
    }
    {
      map['theme'] = Variable<String>(
        $AppStateTable.$convertertheme.toSql(theme),
      );
    }
    {
      map['display_font'] = Variable<String>(
        $AppStateTable.$converterdisplayFont.toSql(displayFont),
      );
    }
    return map;
  }

  AppStateCompanion toCompanion(bool nullToAbsent) {
    return AppStateCompanion(
      id: Value(id),
      totalXp: Value(totalXp),
      heroName: Value(heroName),
      language: Value(language),
      theme: Value(theme),
      displayFont: Value(displayFont),
    );
  }

  factory AppStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppStateRow(
      id: serializer.fromJson<int>(json['id']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      heroName: serializer.fromJson<String>(json['heroName']),
      language: $AppStateTable.$converterlanguage.fromJson(
        serializer.fromJson<String>(json['language']),
      ),
      theme: $AppStateTable.$convertertheme.fromJson(
        serializer.fromJson<String>(json['theme']),
      ),
      displayFont: $AppStateTable.$converterdisplayFont.fromJson(
        serializer.fromJson<String>(json['displayFont']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalXp': serializer.toJson<int>(totalXp),
      'heroName': serializer.toJson<String>(heroName),
      'language': serializer.toJson<String>(
        $AppStateTable.$converterlanguage.toJson(language),
      ),
      'theme': serializer.toJson<String>(
        $AppStateTable.$convertertheme.toJson(theme),
      ),
      'displayFont': serializer.toJson<String>(
        $AppStateTable.$converterdisplayFont.toJson(displayFont),
      ),
    };
  }

  AppStateRow copyWith({
    int? id,
    int? totalXp,
    String? heroName,
    AppLanguage? language,
    AppTheme? theme,
    DisplayFont? displayFont,
  }) => AppStateRow(
    id: id ?? this.id,
    totalXp: totalXp ?? this.totalXp,
    heroName: heroName ?? this.heroName,
    language: language ?? this.language,
    theme: theme ?? this.theme,
    displayFont: displayFont ?? this.displayFont,
  );
  AppStateRow copyWithCompanion(AppStateCompanion data) {
    return AppStateRow(
      id: data.id.present ? data.id.value : this.id,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      heroName: data.heroName.present ? data.heroName.value : this.heroName,
      language: data.language.present ? data.language.value : this.language,
      theme: data.theme.present ? data.theme.value : this.theme,
      displayFont: data.displayFont.present
          ? data.displayFont.value
          : this.displayFont,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppStateRow(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('heroName: $heroName, ')
          ..write('language: $language, ')
          ..write('theme: $theme, ')
          ..write('displayFont: $displayFont')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, totalXp, heroName, language, theme, displayFont);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppStateRow &&
          other.id == this.id &&
          other.totalXp == this.totalXp &&
          other.heroName == this.heroName &&
          other.language == this.language &&
          other.theme == this.theme &&
          other.displayFont == this.displayFont);
}

class AppStateCompanion extends UpdateCompanion<AppStateRow> {
  final Value<int> id;
  final Value<int> totalXp;
  final Value<String> heroName;
  final Value<AppLanguage> language;
  final Value<AppTheme> theme;
  final Value<DisplayFont> displayFont;
  const AppStateCompanion({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.heroName = const Value.absent(),
    this.language = const Value.absent(),
    this.theme = const Value.absent(),
    this.displayFont = const Value.absent(),
  });
  AppStateCompanion.insert({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.heroName = const Value.absent(),
    this.language = const Value.absent(),
    this.theme = const Value.absent(),
    this.displayFont = const Value.absent(),
  });
  static Insertable<AppStateRow> custom({
    Expression<int>? id,
    Expression<int>? totalXp,
    Expression<String>? heroName,
    Expression<String>? language,
    Expression<String>? theme,
    Expression<String>? displayFont,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalXp != null) 'total_xp': totalXp,
      if (heroName != null) 'hero_name': heroName,
      if (language != null) 'language': language,
      if (theme != null) 'theme': theme,
      if (displayFont != null) 'display_font': displayFont,
    });
  }

  AppStateCompanion copyWith({
    Value<int>? id,
    Value<int>? totalXp,
    Value<String>? heroName,
    Value<AppLanguage>? language,
    Value<AppTheme>? theme,
    Value<DisplayFont>? displayFont,
  }) {
    return AppStateCompanion(
      id: id ?? this.id,
      totalXp: totalXp ?? this.totalXp,
      heroName: heroName ?? this.heroName,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      displayFont: displayFont ?? this.displayFont,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (heroName.present) {
      map['hero_name'] = Variable<String>(heroName.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(
        $AppStateTable.$converterlanguage.toSql(language.value),
      );
    }
    if (theme.present) {
      map['theme'] = Variable<String>(
        $AppStateTable.$convertertheme.toSql(theme.value),
      );
    }
    if (displayFont.present) {
      map['display_font'] = Variable<String>(
        $AppStateTable.$converterdisplayFont.toSql(displayFont.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppStateCompanion(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('heroName: $heroName, ')
          ..write('language: $language, ')
          ..write('theme: $theme, ')
          ..write('displayFont: $displayFont')
          ..write(')'))
        .toString();
  }
}

abstract class _$QuestlogDatabase extends GeneratedDatabase {
  _$QuestlogDatabase(QueryExecutor e) : super(e);
  $QuestlogDatabaseManager get managers => $QuestlogDatabaseManager(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $MissionsTable missions = $MissionsTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $RuleQuestsTable ruleQuests = $RuleQuestsTable(this);
  late final $AppStateTable appState = $AppStateTable(this);
  late final Index idxQuestsMission = Index(
    'idx_quests_mission',
    'CREATE INDEX idx_quests_mission ON quests (mission_id)',
  );
  late final Index idxQuestsCompleted = Index(
    'idx_quests_completed',
    'CREATE INDEX idx_quests_completed ON quests (completed_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recurringRules,
    missions,
    quests,
    ruleQuests,
    appState,
    idxQuestsMission,
    idxQuestsCompleted,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('missions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'missions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rule_quests', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int> id,
      required String name,
      required Cadence cadence,
      required DateTime anchorDate,
      Value<int> nextIndex,
      required MissionBonus bonus,
      Value<DateTime?> lastPostedOn,
      required DateTime createdAt,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<Cadence> cadence,
      Value<DateTime> anchorDate,
      Value<int> nextIndex,
      Value<MissionBonus> bonus,
      Value<DateTime?> lastPostedOn,
      Value<DateTime> createdAt,
    });

final class $$RecurringRulesTableReferences
    extends
        BaseReferences<
          _$QuestlogDatabase,
          $RecurringRulesTable,
          RecurringRuleRow
        > {
  $$RecurringRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MissionsTable, List<MissionRow>>
  _missionsRefsTable(_$QuestlogDatabase db) => MultiTypedResultKey.fromTable(
    db.missions,
    aliasName: 'recurring_rules__id__missions__rule_id',
  );

  $$MissionsTableProcessedTableManager get missionsRefs {
    final manager = $$MissionsTableTableManager(
      $_db,
      $_db.missions,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_missionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RuleQuestsTable, List<RuleQuestRow>>
  _ruleQuestsRefsTable(_$QuestlogDatabase db) => MultiTypedResultKey.fromTable(
    db.ruleQuests,
    aliasName: 'recurring_rules__id__rule_quests__rule_id',
  );

  $$RuleQuestsTableProcessedTableManager get ruleQuestsRefs {
    final manager = $$RuleQuestsTableTableManager(
      $_db,
      $_db.ruleQuests,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ruleQuestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringRulesTableFilterComposer
    extends Composer<_$QuestlogDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Cadence, Cadence, String> get cadence =>
      $composableBuilder(
        column: $table.cadence,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get anchorDate =>
      $composableBuilder(
        column: $table.anchorDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get nextIndex => $composableBuilder(
    column: $table.nextIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MissionBonus, MissionBonus, String>
  get bonus => $composableBuilder(
    column: $table.bonus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get lastPostedOn => $composableBuilder(
    column: $table.lastPostedOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> missionsRefs(
    Expression<bool> Function($$MissionsTableFilterComposer f) f,
  ) {
    final $$MissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableFilterComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ruleQuestsRefs(
    Expression<bool> Function($$RuleQuestsTableFilterComposer f) f,
  ) {
    final $$RuleQuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ruleQuests,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RuleQuestsTableFilterComposer(
            $db: $db,
            $table: $db.ruleQuests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextIndex => $composableBuilder(
    column: $table.nextIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bonus => $composableBuilder(
    column: $table.bonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPostedOn => $composableBuilder(
    column: $table.lastPostedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Cadence, String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get anchorDate =>
      $composableBuilder(
        column: $table.anchorDate,
        builder: (column) => column,
      );

  GeneratedColumn<int> get nextIndex =>
      $composableBuilder(column: $table.nextIndex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MissionBonus, String> get bonus =>
      $composableBuilder(column: $table.bonus, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get lastPostedOn =>
      $composableBuilder(
        column: $table.lastPostedOn,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> missionsRefs<T extends Object>(
    Expression<T> Function($$MissionsTableAnnotationComposer a) f,
  ) {
    final $$MissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ruleQuestsRefs<T extends Object>(
    Expression<T> Function($$RuleQuestsTableAnnotationComposer a) f,
  ) {
    final $$RuleQuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ruleQuests,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RuleQuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.ruleQuests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $RecurringRulesTable,
          RecurringRuleRow,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (RecurringRuleRow, $$RecurringRulesTableReferences),
          RecurringRuleRow,
          PrefetchHooks Function({bool missionsRefs, bool ruleQuestsRefs})
        > {
  $$RecurringRulesTableTableManager(
    _$QuestlogDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Cadence> cadence = const Value.absent(),
                Value<DateTime> anchorDate = const Value.absent(),
                Value<int> nextIndex = const Value.absent(),
                Value<MissionBonus> bonus = const Value.absent(),
                Value<DateTime?> lastPostedOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                name: name,
                cadence: cadence,
                anchorDate: anchorDate,
                nextIndex: nextIndex,
                bonus: bonus,
                lastPostedOn: lastPostedOn,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required Cadence cadence,
                required DateTime anchorDate,
                Value<int> nextIndex = const Value.absent(),
                required MissionBonus bonus,
                Value<DateTime?> lastPostedOn = const Value.absent(),
                required DateTime createdAt,
              }) => RecurringRulesCompanion.insert(
                id: id,
                name: name,
                cadence: cadence,
                anchorDate: anchorDate,
                nextIndex: nextIndex,
                bonus: bonus,
                lastPostedOn: lastPostedOn,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringRulesTable, RecurringRuleRow>(table),
                  $$RecurringRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({missionsRefs = false, ruleQuestsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (missionsRefs) db.missions,
                    if (ruleQuestsRefs) db.ruleQuests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (missionsRefs)
                        await $_getPrefetchedDataByColumns<
                          RecurringRuleRow,
                          $RecurringRulesTable,
                          MissionRow,
                          $MissionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RecurringRulesTableReferences
                              ._missionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringRulesTableReferences(
                                db,
                                table,
                                p0,
                              ).missionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'rule_id',
                          typedResults: items,
                        ),
                      if (ruleQuestsRefs)
                        await $_getPrefetchedDataByColumns<
                          RecurringRuleRow,
                          $RecurringRulesTable,
                          RuleQuestRow,
                          $RuleQuestsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RecurringRulesTableReferences
                              ._ruleQuestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringRulesTableReferences(
                                db,
                                table,
                                p0,
                              ).ruleQuestsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'rule_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $RecurringRulesTable,
      RecurringRuleRow,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (RecurringRuleRow, $$RecurringRulesTableReferences),
      RecurringRuleRow,
      PrefetchHooks Function({bool missionsRefs, bool ruleQuestsRefs})
    >;
typedef $$MissionsTableCreateCompanionBuilder = MissionsCompanion Function({
  Value<int> id,
  required String name,
  required MissionBonus bonus,
  Value<MissionStatus> status,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int?> awardedBonus,
  Value<int?> ruleId,
});
typedef $$MissionsTableUpdateCompanionBuilder = MissionsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<MissionBonus> bonus,
  Value<MissionStatus> status,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> awardedBonus,
  Value<int?> ruleId,
});

final class $$MissionsTableReferences
    extends BaseReferences<_$QuestlogDatabase, $MissionsTable, MissionRow> {
  $$MissionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecurringRulesTable _ruleIdTable(_$QuestlogDatabase db) =>
      db.recurringRules.createAlias('missions__rule_id__recurring_rules__id');

  $$RecurringRulesTableProcessedTableManager? get ruleId {
    final $_column = $_itemColumn<int>('rule_id');
    if ($_column == null) return null;
    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QuestsTable, List<QuestRow>> _questsRefsTable(
    _$QuestlogDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quests,
    aliasName: 'missions__id__quests__mission_id',
  );

  $$QuestsTableProcessedTableManager get questsRefs {
    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.missionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_questsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MissionsTableFilterComposer
    extends Composer<_$QuestlogDatabase, $MissionsTable> {
  $$MissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MissionBonus, MissionBonus, String>
  get bonus => $composableBuilder(
    column: $table.bonus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MissionStatus, MissionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awardedBonus => $composableBuilder(
    column: $table.awardedBonus,
    builder: (column) => ColumnFilters(column),
  );

  $$RecurringRulesTableFilterComposer get ruleId {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> questsRefs(
    Expression<bool> Function($$QuestsTableFilterComposer f) f,
  ) {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.missionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MissionsTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $MissionsTable> {
  $$MissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bonus => $composableBuilder(
    column: $table.bonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awardedBonus => $composableBuilder(
    column: $table.awardedBonus,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecurringRulesTableOrderingComposer get ruleId {
    final $$RecurringRulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableOrderingComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MissionsTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $MissionsTable> {
  $$MissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MissionBonus, String> get bonus =>
      $composableBuilder(column: $table.bonus, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MissionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awardedBonus => $composableBuilder(
    column: $table.awardedBonus,
    builder: (column) => column,
  );

  $$RecurringRulesTableAnnotationComposer get ruleId {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> questsRefs<T extends Object>(
    Expression<T> Function($$QuestsTableAnnotationComposer a) f,
  ) {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.missionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MissionsTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $MissionsTable,
          MissionRow,
          $$MissionsTableFilterComposer,
          $$MissionsTableOrderingComposer,
          $$MissionsTableAnnotationComposer,
          $$MissionsTableCreateCompanionBuilder,
          $$MissionsTableUpdateCompanionBuilder,
          (MissionRow, $$MissionsTableReferences),
          MissionRow,
          PrefetchHooks Function({bool ruleId, bool questsRefs})
        > {
  $$MissionsTableTableManager(_$QuestlogDatabase db, $MissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<MissionBonus> bonus = const Value.absent(),
                Value<MissionStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> awardedBonus = const Value.absent(),
                Value<int?> ruleId = const Value.absent(),
              }) => MissionsCompanion(
                id: id,
                name: name,
                bonus: bonus,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                awardedBonus: awardedBonus,
                ruleId: ruleId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required MissionBonus bonus,
                Value<MissionStatus> status = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> awardedBonus = const Value.absent(),
                Value<int?> ruleId = const Value.absent(),
              }) => MissionsCompanion.insert(
                id: id,
                name: name,
                bonus: bonus,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                awardedBonus: awardedBonus,
                ruleId: ruleId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MissionsTable, MissionRow>(table),
                  $$MissionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ruleId = false, questsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (questsRefs) db.quests],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ruleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ruleId,
                        referencedTable: $$MissionsTableReferences._ruleIdTable(
                          db,
                        ),
                        referencedColumn: $$MissionsTableReferences
                            ._ruleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questsRefs)
                    await $_getPrefetchedDataByColumns<
                      MissionRow,
                      $MissionsTable,
                      QuestRow,
                      $QuestsTable
                    >(
                      currentTable: table,
                      referencedTable: $$MissionsTableReferences
                          ._questsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MissionsTableReferences(db, table, p0).questsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'mission_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $MissionsTable,
      MissionRow,
      $$MissionsTableFilterComposer,
      $$MissionsTableOrderingComposer,
      $$MissionsTableAnnotationComposer,
      $$MissionsTableCreateCompanionBuilder,
      $$MissionsTableUpdateCompanionBuilder,
      (MissionRow, $$MissionsTableReferences),
      MissionRow,
      PrefetchHooks Function({bool ruleId, bool questsRefs})
    >;
typedef $$QuestsTableCreateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> note,
  required Difficulty difficulty,
  Value<int?> missionId,
  required int sortOrder,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int?> awardedXp,
});
typedef $$QuestsTableUpdateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> note,
  Value<Difficulty> difficulty,
  Value<int?> missionId,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> awardedXp,
});

final class $$QuestsTableReferences
    extends BaseReferences<_$QuestlogDatabase, $QuestsTable, QuestRow> {
  $$QuestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MissionsTable _missionIdTable(_$QuestlogDatabase db) =>
      db.missions.createAlias('quests__mission_id__missions__id');

  $$MissionsTableProcessedTableManager? get missionId {
    final $_column = $_itemColumn<int>('mission_id');
    if ($_column == null) return null;
    final manager = $$MissionsTableTableManager(
      $_db,
      $_db.missions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_missionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestsTableFilterComposer
    extends Composer<_$QuestlogDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Difficulty, Difficulty, String>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awardedXp => $composableBuilder(
    column: $table.awardedXp,
    builder: (column) => ColumnFilters(column),
  );

  $$MissionsTableFilterComposer get missionId {
    final $$MissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.missionId,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableFilterComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awardedXp => $composableBuilder(
    column: $table.awardedXp,
    builder: (column) => ColumnOrderings(column),
  );

  $$MissionsTableOrderingComposer get missionId {
    final $$MissionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.missionId,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableOrderingComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $QuestsTable> {
  $$QuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Difficulty, String> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awardedXp =>
      $composableBuilder(column: $table.awardedXp, builder: (column) => column);

  $$MissionsTableAnnotationComposer get missionId {
    final $$MissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.missionId,
      referencedTable: $db.missions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.missions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $QuestsTable,
          QuestRow,
          $$QuestsTableFilterComposer,
          $$QuestsTableOrderingComposer,
          $$QuestsTableAnnotationComposer,
          $$QuestsTableCreateCompanionBuilder,
          $$QuestsTableUpdateCompanionBuilder,
          (QuestRow, $$QuestsTableReferences),
          QuestRow,
          PrefetchHooks Function({bool missionId})
        > {
  $$QuestsTableTableManager(_$QuestlogDatabase db, $QuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<Difficulty> difficulty = const Value.absent(),
                Value<int?> missionId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> awardedXp = const Value.absent(),
              }) => QuestsCompanion(
                id: id,
                name: name,
                note: note,
                difficulty: difficulty,
                missionId: missionId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                completedAt: completedAt,
                awardedXp: awardedXp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> note = const Value.absent(),
                required Difficulty difficulty,
                Value<int?> missionId = const Value.absent(),
                required int sortOrder,
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> awardedXp = const Value.absent(),
              }) => QuestsCompanion.insert(
                id: id,
                name: name,
                note: note,
                difficulty: difficulty,
                missionId: missionId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                completedAt: completedAt,
                awardedXp: awardedXp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestsTable, QuestRow>(table),
                  $$QuestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({missionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (missionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.missionId,
                        referencedTable: $$QuestsTableReferences
                            ._missionIdTable(db),
                        referencedColumn: $$QuestsTableReferences
                            ._missionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $QuestsTable,
      QuestRow,
      $$QuestsTableFilterComposer,
      $$QuestsTableOrderingComposer,
      $$QuestsTableAnnotationComposer,
      $$QuestsTableCreateCompanionBuilder,
      $$QuestsTableUpdateCompanionBuilder,
      (QuestRow, $$QuestsTableReferences),
      QuestRow,
      PrefetchHooks Function({bool missionId})
    >;
typedef $$RuleQuestsTableCreateCompanionBuilder = RuleQuestsCompanion Function({
  Value<int> id,
  required int ruleId,
  required String name,
  required Difficulty difficulty,
  required int sortOrder,
});
typedef $$RuleQuestsTableUpdateCompanionBuilder = RuleQuestsCompanion Function({
  Value<int> id,
  Value<int> ruleId,
  Value<String> name,
  Value<Difficulty> difficulty,
  Value<int> sortOrder,
});

final class $$RuleQuestsTableReferences
    extends BaseReferences<_$QuestlogDatabase, $RuleQuestsTable, RuleQuestRow> {
  $$RuleQuestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecurringRulesTable _ruleIdTable(_$QuestlogDatabase db) => db
      .recurringRules
      .createAlias('rule_quests__rule_id__recurring_rules__id');

  $$RecurringRulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<int>('rule_id')!;

    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RuleQuestsTableFilterComposer
    extends Composer<_$QuestlogDatabase, $RuleQuestsTable> {
  $$RuleQuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Difficulty, Difficulty, String>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$RecurringRulesTableFilterComposer get ruleId {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RuleQuestsTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $RuleQuestsTable> {
  $$RuleQuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecurringRulesTableOrderingComposer get ruleId {
    final $$RecurringRulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableOrderingComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RuleQuestsTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $RuleQuestsTable> {
  $$RuleQuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Difficulty, String> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$RecurringRulesTableAnnotationComposer get ruleId {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RuleQuestsTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $RuleQuestsTable,
          RuleQuestRow,
          $$RuleQuestsTableFilterComposer,
          $$RuleQuestsTableOrderingComposer,
          $$RuleQuestsTableAnnotationComposer,
          $$RuleQuestsTableCreateCompanionBuilder,
          $$RuleQuestsTableUpdateCompanionBuilder,
          (RuleQuestRow, $$RuleQuestsTableReferences),
          RuleQuestRow,
          PrefetchHooks Function({bool ruleId})
        > {
  $$RuleQuestsTableTableManager(_$QuestlogDatabase db, $RuleQuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuleQuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuleQuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleQuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Difficulty> difficulty = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => RuleQuestsCompanion(
                id: id,
                ruleId: ruleId,
                name: name,
                difficulty: difficulty,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ruleId,
                required String name,
                required Difficulty difficulty,
                required int sortOrder,
              }) => RuleQuestsCompanion.insert(
                id: id,
                ruleId: ruleId,
                name: name,
                difficulty: difficulty,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RuleQuestsTable, RuleQuestRow>(table),
                  $$RuleQuestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ruleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ruleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ruleId,
                        referencedTable: $$RuleQuestsTableReferences
                            ._ruleIdTable(db),
                        referencedColumn: $$RuleQuestsTableReferences
                            ._ruleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RuleQuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $RuleQuestsTable,
      RuleQuestRow,
      $$RuleQuestsTableFilterComposer,
      $$RuleQuestsTableOrderingComposer,
      $$RuleQuestsTableAnnotationComposer,
      $$RuleQuestsTableCreateCompanionBuilder,
      $$RuleQuestsTableUpdateCompanionBuilder,
      (RuleQuestRow, $$RuleQuestsTableReferences),
      RuleQuestRow,
      PrefetchHooks Function({bool ruleId})
    >;
typedef $$AppStateTableCreateCompanionBuilder = AppStateCompanion Function({
  Value<int> id,
  Value<int> totalXp,
  Value<String> heroName,
  Value<AppLanguage> language,
  Value<AppTheme> theme,
  Value<DisplayFont> displayFont,
});
typedef $$AppStateTableUpdateCompanionBuilder = AppStateCompanion Function({
  Value<int> id,
  Value<int> totalXp,
  Value<String> heroName,
  Value<AppLanguage> language,
  Value<AppTheme> theme,
  Value<DisplayFont> displayFont,
});

class $$AppStateTableFilterComposer
    extends Composer<_$QuestlogDatabase, $AppStateTable> {
  $$AppStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroName => $composableBuilder(
    column: $table.heroName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppLanguage, AppLanguage, String>
  get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AppTheme, AppTheme, String> get theme =>
      $composableBuilder(
        column: $table.theme,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DisplayFont, DisplayFont, String>
  get displayFont => $composableBuilder(
    column: $table.displayFont,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$AppStateTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $AppStateTable> {
  $$AppStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroName => $composableBuilder(
    column: $table.heroName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayFont => $composableBuilder(
    column: $table.displayFont,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppStateTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $AppStateTable> {
  $$AppStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<String> get heroName =>
      $composableBuilder(column: $table.heroName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppLanguage, String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppTheme, String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DisplayFont, String> get displayFont =>
      $composableBuilder(
        column: $table.displayFont,
        builder: (column) => column,
      );
}

class $$AppStateTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $AppStateTable,
          AppStateRow,
          $$AppStateTableFilterComposer,
          $$AppStateTableOrderingComposer,
          $$AppStateTableAnnotationComposer,
          $$AppStateTableCreateCompanionBuilder,
          $$AppStateTableUpdateCompanionBuilder,
          (
            AppStateRow,
            BaseReferences<_$QuestlogDatabase, $AppStateTable, AppStateRow>,
          ),
          AppStateRow,
          PrefetchHooks Function()
        > {
  $$AppStateTableTableManager(_$QuestlogDatabase db, $AppStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<String> heroName = const Value.absent(),
                Value<AppLanguage> language = const Value.absent(),
                Value<AppTheme> theme = const Value.absent(),
                Value<DisplayFont> displayFont = const Value.absent(),
              }) => AppStateCompanion(
                id: id,
                totalXp: totalXp,
                heroName: heroName,
                language: language,
                theme: theme,
                displayFont: displayFont,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<String> heroName = const Value.absent(),
                Value<AppLanguage> language = const Value.absent(),
                Value<AppTheme> theme = const Value.absent(),
                Value<DisplayFont> displayFont = const Value.absent(),
              }) => AppStateCompanion.insert(
                id: id,
                totalXp: totalXp,
                heroName: heroName,
                language: language,
                theme: theme,
                displayFont: displayFont,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppStateTable, AppStateRow>(table),
                  BaseReferences<
                    _$QuestlogDatabase,
                    $AppStateTable,
                    AppStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppStateTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $AppStateTable,
      AppStateRow,
      $$AppStateTableFilterComposer,
      $$AppStateTableOrderingComposer,
      $$AppStateTableAnnotationComposer,
      $$AppStateTableCreateCompanionBuilder,
      $$AppStateTableUpdateCompanionBuilder,
      (
        AppStateRow,
        BaseReferences<_$QuestlogDatabase, $AppStateTable, AppStateRow>,
      ),
      AppStateRow,
      PrefetchHooks Function()
    >;

class $QuestlogDatabaseManager {
  final _$QuestlogDatabase _db;
  $QuestlogDatabaseManager(this._db);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$MissionsTableTableManager get missions =>
      $$MissionsTableTableManager(_db, _db.missions);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$RuleQuestsTableTableManager get ruleQuests =>
      $$RuleQuestsTableTableManager(_db, _db.ruleQuests);
  $$AppStateTableTableManager get appState =>
      $$AppStateTableTableManager(_db, _db.appState);
}
