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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    sortOrder,
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
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
  final int sortOrder;
  final int? awardedBonus;
  final int? ruleId;
  const MissionRow({
    required this.id,
    required this.name,
    required this.bonus,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.sortOrder,
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
    map['sort_order'] = Variable<int>(sortOrder);
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
      sortOrder: Value(sortOrder),
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
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
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
      'sortOrder': serializer.toJson<int>(sortOrder),
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
    int? sortOrder,
    Value<int?> awardedBonus = const Value.absent(),
    Value<int?> ruleId = const Value.absent(),
  }) => MissionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    bonus: bonus ?? this.bonus,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    sortOrder: sortOrder ?? this.sortOrder,
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
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
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
          ..write('sortOrder: $sortOrder, ')
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
    sortOrder,
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
          other.sortOrder == this.sortOrder &&
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
  final Value<int> sortOrder;
  final Value<int?> awardedBonus;
  final Value<int?> ruleId;
  const MissionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bonus = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
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
    this.sortOrder = const Value.absent(),
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
    Expression<int>? sortOrder,
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
      if (sortOrder != null) 'sort_order': sortOrder,
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
    Value<int>? sortOrder,
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
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
          ..write('sortOrder: $sortOrder, ')
          ..write('awardedBonus: $awardedBonus, ')
          ..write('ruleId: $ruleId')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    check: () => ComparableExpr(location.length).isSmallerOrEqualValue(120),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CalendarEventsTable.$converterstartDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CalendarEventsTable.$converterendDate);
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    true,
    check: () => ComparableExpr(startMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    true,
    check: () => ComparableExpr(endMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatKindMeta = const VerificationMeta(
    'repeatKind',
  );
  @override
  late final GeneratedColumn<String> repeatKind = GeneratedColumn<String>(
    'repeat_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _easterOffsetMeta = const VerificationMeta(
    'easterOffset',
  );
  @override
  late final GeneratedColumn<int> easterOffset = GeneratedColumn<int>(
    'easter_offset',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nthMonthMeta = const VerificationMeta(
    'nthMonth',
  );
  @override
  late final GeneratedColumn<int> nthMonth = GeneratedColumn<int>(
    'nth_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nthWeekdayMeta = const VerificationMeta(
    'nthWeekday',
  );
  @override
  late final GeneratedColumn<int> nthWeekday = GeneratedColumn<int>(
    'nth_weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nthOrdinalMeta = const VerificationMeta(
    'nthOrdinal',
  );
  @override
  late final GeneratedColumn<int> nthOrdinal = GeneratedColumn<int>(
    'nth_ordinal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> repeatEnd =
      GeneratedColumn<String>(
        'repeat_end',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CalendarEventsTable.$converterrepeatEndn);
  static const VerificationMeta _onBoardMeta = const VerificationMeta(
    'onBoard',
  );
  @override
  late final GeneratedColumn<bool> onBoard = GeneratedColumn<bool>(
    'on_board',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("on_board" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    note,
    location,
    eventType,
    startDate,
    endDate,
    startMinute,
    endMinute,
    repeatKind,
    easterOffset,
    nthMonth,
    nthWeekday,
    nthOrdinal,
    repeatEnd,
    onBoard,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEventRow> instance, {
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
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    }
    if (data.containsKey('repeat_kind')) {
      context.handle(
        _repeatKindMeta,
        repeatKind.isAcceptableOrUnknown(data['repeat_kind']!, _repeatKindMeta),
      );
    }
    if (data.containsKey('easter_offset')) {
      context.handle(
        _easterOffsetMeta,
        easterOffset.isAcceptableOrUnknown(
          data['easter_offset']!,
          _easterOffsetMeta,
        ),
      );
    }
    if (data.containsKey('nth_month')) {
      context.handle(
        _nthMonthMeta,
        nthMonth.isAcceptableOrUnknown(data['nth_month']!, _nthMonthMeta),
      );
    }
    if (data.containsKey('nth_weekday')) {
      context.handle(
        _nthWeekdayMeta,
        nthWeekday.isAcceptableOrUnknown(data['nth_weekday']!, _nthWeekdayMeta),
      );
    }
    if (data.containsKey('nth_ordinal')) {
      context.handle(
        _nthOrdinalMeta,
        nthOrdinal.isAcceptableOrUnknown(data['nth_ordinal']!, _nthOrdinalMeta),
      );
    }
    if (data.containsKey('on_board')) {
      context.handle(
        _onBoardMeta,
        onBoard.isAcceptableOrUnknown(data['on_board']!, _onBoardMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEventRow(
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
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      startDate: $CalendarEventsTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $CalendarEventsTable.$converterendDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        )!,
      ),
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      ),
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      ),
      repeatKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_kind'],
      )!,
      easterOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}easter_offset'],
      ),
      nthMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nth_month'],
      ),
      nthWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nth_weekday'],
      ),
      nthOrdinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nth_ordinal'],
      ),
      repeatEnd: $CalendarEventsTable.$converterrepeatEndn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}repeat_end'],
        ),
      ),
      onBoard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}on_board'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterstartDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $converterendDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $converterrepeatEnd =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterrepeatEndn =
      NullAwareTypeConverter.wrap($converterrepeatEnd);
}

class CalendarEventRow extends DataClass
    implements Insertable<CalendarEventRow> {
  final int id;
  final String name;
  final String? note;
  final String? location;

  /// An `EventType.key`; no CHECK, so an unknown value from newer data is kept.
  final String eventType;
  final DateTime startDate;
  final DateTime endDate;
  final int? startMinute;
  final int? endMinute;

  /// none | daily | weekly | monthly | yearly | easter | nthWeekday
  final String repeatKind;
  final int? easterOffset;
  final int? nthMonth;
  final int? nthWeekday;
  final int? nthOrdinal;
  final DateTime? repeatEnd;
  final bool onBoard;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CalendarEventRow({
    required this.id,
    required this.name,
    this.note,
    this.location,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    this.startMinute,
    this.endMinute,
    required this.repeatKind,
    this.easterOffset,
    this.nthMonth,
    this.nthWeekday,
    this.nthOrdinal,
    this.repeatEnd,
    required this.onBoard,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['event_type'] = Variable<String>(eventType);
    {
      map['start_date'] = Variable<String>(
        $CalendarEventsTable.$converterstartDate.toSql(startDate),
      );
    }
    {
      map['end_date'] = Variable<String>(
        $CalendarEventsTable.$converterendDate.toSql(endDate),
      );
    }
    if (!nullToAbsent || startMinute != null) {
      map['start_minute'] = Variable<int>(startMinute);
    }
    if (!nullToAbsent || endMinute != null) {
      map['end_minute'] = Variable<int>(endMinute);
    }
    map['repeat_kind'] = Variable<String>(repeatKind);
    if (!nullToAbsent || easterOffset != null) {
      map['easter_offset'] = Variable<int>(easterOffset);
    }
    if (!nullToAbsent || nthMonth != null) {
      map['nth_month'] = Variable<int>(nthMonth);
    }
    if (!nullToAbsent || nthWeekday != null) {
      map['nth_weekday'] = Variable<int>(nthWeekday);
    }
    if (!nullToAbsent || nthOrdinal != null) {
      map['nth_ordinal'] = Variable<int>(nthOrdinal);
    }
    if (!nullToAbsent || repeatEnd != null) {
      map['repeat_end'] = Variable<String>(
        $CalendarEventsTable.$converterrepeatEndn.toSql(repeatEnd),
      );
    }
    map['on_board'] = Variable<bool>(onBoard);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      eventType: Value(eventType),
      startDate: Value(startDate),
      endDate: Value(endDate),
      startMinute: startMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinute),
      endMinute: endMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(endMinute),
      repeatKind: Value(repeatKind),
      easterOffset: easterOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(easterOffset),
      nthMonth: nthMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(nthMonth),
      nthWeekday: nthWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(nthWeekday),
      nthOrdinal: nthOrdinal == null && nullToAbsent
          ? const Value.absent()
          : Value(nthOrdinal),
      repeatEnd: repeatEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatEnd),
      onBoard: Value(onBoard),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CalendarEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEventRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      location: serializer.fromJson<String?>(json['location']),
      eventType: serializer.fromJson<String>(json['eventType']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      startMinute: serializer.fromJson<int?>(json['startMinute']),
      endMinute: serializer.fromJson<int?>(json['endMinute']),
      repeatKind: serializer.fromJson<String>(json['repeatKind']),
      easterOffset: serializer.fromJson<int?>(json['easterOffset']),
      nthMonth: serializer.fromJson<int?>(json['nthMonth']),
      nthWeekday: serializer.fromJson<int?>(json['nthWeekday']),
      nthOrdinal: serializer.fromJson<int?>(json['nthOrdinal']),
      repeatEnd: serializer.fromJson<DateTime?>(json['repeatEnd']),
      onBoard: serializer.fromJson<bool>(json['onBoard']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
      'location': serializer.toJson<String?>(location),
      'eventType': serializer.toJson<String>(eventType),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'startMinute': serializer.toJson<int?>(startMinute),
      'endMinute': serializer.toJson<int?>(endMinute),
      'repeatKind': serializer.toJson<String>(repeatKind),
      'easterOffset': serializer.toJson<int?>(easterOffset),
      'nthMonth': serializer.toJson<int?>(nthMonth),
      'nthWeekday': serializer.toJson<int?>(nthWeekday),
      'nthOrdinal': serializer.toJson<int?>(nthOrdinal),
      'repeatEnd': serializer.toJson<DateTime?>(repeatEnd),
      'onBoard': serializer.toJson<bool>(onBoard),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CalendarEventRow copyWith({
    int? id,
    String? name,
    Value<String?> note = const Value.absent(),
    Value<String?> location = const Value.absent(),
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    Value<int?> startMinute = const Value.absent(),
    Value<int?> endMinute = const Value.absent(),
    String? repeatKind,
    Value<int?> easterOffset = const Value.absent(),
    Value<int?> nthMonth = const Value.absent(),
    Value<int?> nthWeekday = const Value.absent(),
    Value<int?> nthOrdinal = const Value.absent(),
    Value<DateTime?> repeatEnd = const Value.absent(),
    bool? onBoard,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CalendarEventRow(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
    location: location.present ? location.value : this.location,
    eventType: eventType ?? this.eventType,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    startMinute: startMinute.present ? startMinute.value : this.startMinute,
    endMinute: endMinute.present ? endMinute.value : this.endMinute,
    repeatKind: repeatKind ?? this.repeatKind,
    easterOffset: easterOffset.present ? easterOffset.value : this.easterOffset,
    nthMonth: nthMonth.present ? nthMonth.value : this.nthMonth,
    nthWeekday: nthWeekday.present ? nthWeekday.value : this.nthWeekday,
    nthOrdinal: nthOrdinal.present ? nthOrdinal.value : this.nthOrdinal,
    repeatEnd: repeatEnd.present ? repeatEnd.value : this.repeatEnd,
    onBoard: onBoard ?? this.onBoard,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CalendarEventRow copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEventRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      location: data.location.present ? data.location.value : this.location,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      repeatKind: data.repeatKind.present
          ? data.repeatKind.value
          : this.repeatKind,
      easterOffset: data.easterOffset.present
          ? data.easterOffset.value
          : this.easterOffset,
      nthMonth: data.nthMonth.present ? data.nthMonth.value : this.nthMonth,
      nthWeekday: data.nthWeekday.present
          ? data.nthWeekday.value
          : this.nthWeekday,
      nthOrdinal: data.nthOrdinal.present
          ? data.nthOrdinal.value
          : this.nthOrdinal,
      repeatEnd: data.repeatEnd.present ? data.repeatEnd.value : this.repeatEnd,
      onBoard: data.onBoard.present ? data.onBoard.value : this.onBoard,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('location: $location, ')
          ..write('eventType: $eventType, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('repeatKind: $repeatKind, ')
          ..write('easterOffset: $easterOffset, ')
          ..write('nthMonth: $nthMonth, ')
          ..write('nthWeekday: $nthWeekday, ')
          ..write('nthOrdinal: $nthOrdinal, ')
          ..write('repeatEnd: $repeatEnd, ')
          ..write('onBoard: $onBoard, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    note,
    location,
    eventType,
    startDate,
    endDate,
    startMinute,
    endMinute,
    repeatKind,
    easterOffset,
    nthMonth,
    nthWeekday,
    nthOrdinal,
    repeatEnd,
    onBoard,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEventRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.location == this.location &&
          other.eventType == this.eventType &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.repeatKind == this.repeatKind &&
          other.easterOffset == this.easterOffset &&
          other.nthMonth == this.nthMonth &&
          other.nthWeekday == this.nthWeekday &&
          other.nthOrdinal == this.nthOrdinal &&
          other.repeatEnd == this.repeatEnd &&
          other.onBoard == this.onBoard &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEventRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> note;
  final Value<String?> location;
  final Value<String> eventType;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int?> startMinute;
  final Value<int?> endMinute;
  final Value<String> repeatKind;
  final Value<int?> easterOffset;
  final Value<int?> nthMonth;
  final Value<int?> nthWeekday;
  final Value<int?> nthOrdinal;
  final Value<DateTime?> repeatEnd;
  final Value<bool> onBoard;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.location = const Value.absent(),
    this.eventType = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.repeatKind = const Value.absent(),
    this.easterOffset = const Value.absent(),
    this.nthMonth = const Value.absent(),
    this.nthWeekday = const Value.absent(),
    this.nthOrdinal = const Value.absent(),
    this.repeatEnd = const Value.absent(),
    this.onBoard = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
    this.location = const Value.absent(),
    required String eventType,
    required DateTime startDate,
    required DateTime endDate,
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.repeatKind = const Value.absent(),
    this.easterOffset = const Value.absent(),
    this.nthMonth = const Value.absent(),
    this.nthWeekday = const Value.absent(),
    this.nthOrdinal = const Value.absent(),
    this.repeatEnd = const Value.absent(),
    this.onBoard = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       eventType = Value(eventType),
       startDate = Value(startDate),
       endDate = Value(endDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CalendarEventRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<String>? location,
    Expression<String>? eventType,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<String>? repeatKind,
    Expression<int>? easterOffset,
    Expression<int>? nthMonth,
    Expression<int>? nthWeekday,
    Expression<int>? nthOrdinal,
    Expression<String>? repeatEnd,
    Expression<bool>? onBoard,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (location != null) 'location': location,
      if (eventType != null) 'event_type': eventType,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (repeatKind != null) 'repeat_kind': repeatKind,
      if (easterOffset != null) 'easter_offset': easterOffset,
      if (nthMonth != null) 'nth_month': nthMonth,
      if (nthWeekday != null) 'nth_weekday': nthWeekday,
      if (nthOrdinal != null) 'nth_ordinal': nthOrdinal,
      if (repeatEnd != null) 'repeat_end': repeatEnd,
      if (onBoard != null) 'on_board': onBoard,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CalendarEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? note,
    Value<String?>? location,
    Value<String>? eventType,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<int?>? startMinute,
    Value<int?>? endMinute,
    Value<String>? repeatKind,
    Value<int?>? easterOffset,
    Value<int?>? nthMonth,
    Value<int?>? nthWeekday,
    Value<int?>? nthOrdinal,
    Value<DateTime?>? repeatEnd,
    Value<bool>? onBoard,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      repeatKind: repeatKind ?? this.repeatKind,
      easterOffset: easterOffset ?? this.easterOffset,
      nthMonth: nthMonth ?? this.nthMonth,
      nthWeekday: nthWeekday ?? this.nthWeekday,
      nthOrdinal: nthOrdinal ?? this.nthOrdinal,
      repeatEnd: repeatEnd ?? this.repeatEnd,
      onBoard: onBoard ?? this.onBoard,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $CalendarEventsTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $CalendarEventsTable.$converterendDate.toSql(endDate.value),
      );
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (repeatKind.present) {
      map['repeat_kind'] = Variable<String>(repeatKind.value);
    }
    if (easterOffset.present) {
      map['easter_offset'] = Variable<int>(easterOffset.value);
    }
    if (nthMonth.present) {
      map['nth_month'] = Variable<int>(nthMonth.value);
    }
    if (nthWeekday.present) {
      map['nth_weekday'] = Variable<int>(nthWeekday.value);
    }
    if (nthOrdinal.present) {
      map['nth_ordinal'] = Variable<int>(nthOrdinal.value);
    }
    if (repeatEnd.present) {
      map['repeat_end'] = Variable<String>(
        $CalendarEventsTable.$converterrepeatEndn.toSql(repeatEnd.value),
      );
    }
    if (onBoard.present) {
      map['on_board'] = Variable<bool>(onBoard.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('location: $location, ')
          ..write('eventType: $eventType, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('repeatKind: $repeatKind, ')
          ..write('easterOffset: $easterOffset, ')
          ..write('nthMonth: $nthMonth, ')
          ..write('nthWeekday: $nthWeekday, ')
          ..write('nthOrdinal: $nthOrdinal, ')
          ..write('repeatEnd: $repeatEnd, ')
          ..write('onBoard: $onBoard, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  @override
  late final GeneratedColumnWithTypeConverter<BoardSection?, String> board =
      GeneratedColumn<String>(
        'board',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<BoardSection?>($QuestsTable.$converterboardn);
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
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_events (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    note,
    difficulty,
    missionId,
    board,
    sortOrder,
    createdAt,
    completedAt,
    awardedXp,
    eventId,
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
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
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
      board: $QuestsTable.$converterboardn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}board'],
        ),
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
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      ),
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Difficulty, String, String> $converterdifficulty =
      const EnumNameConverter<Difficulty>(Difficulty.values);
  static JsonTypeConverter2<BoardSection, String, String> $converterboard =
      const EnumNameConverter<BoardSection>(BoardSection.values);
  static JsonTypeConverter2<BoardSection?, String?, String?> $converterboardn =
      JsonTypeConverter2.asNullable($converterboard);
}

class QuestRow extends DataClass implements Insertable<QuestRow> {
  final int id;
  final String name;
  final String? note;
  final Difficulty difficulty;
  final int? missionId;

  /// Null: not on the Board. Quests without a Mission are always on it.
  final BoardSection? board;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? awardedXp;

  /// The calendar event of the Quest's Deadline. Deleting the event only clears
  /// this link; the Quest stays.
  final int? eventId;
  const QuestRow({
    required this.id,
    required this.name,
    this.note,
    required this.difficulty,
    this.missionId,
    this.board,
    required this.sortOrder,
    required this.createdAt,
    this.completedAt,
    this.awardedXp,
    this.eventId,
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
    if (!nullToAbsent || board != null) {
      map['board'] = Variable<String>(
        $QuestsTable.$converterboardn.toSql(board),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || awardedXp != null) {
      map['awarded_xp'] = Variable<int>(awardedXp);
    }
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<int>(eventId);
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
      board: board == null && nullToAbsent
          ? const Value.absent()
          : Value(board),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      awardedXp: awardedXp == null && nullToAbsent
          ? const Value.absent()
          : Value(awardedXp),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
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
      board: $QuestsTable.$converterboardn.fromJson(
        serializer.fromJson<String?>(json['board']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      awardedXp: serializer.fromJson<int?>(json['awardedXp']),
      eventId: serializer.fromJson<int?>(json['eventId']),
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
      'board': serializer.toJson<String?>(
        $QuestsTable.$converterboardn.toJson(board),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'awardedXp': serializer.toJson<int?>(awardedXp),
      'eventId': serializer.toJson<int?>(eventId),
    };
  }

  QuestRow copyWith({
    int? id,
    String? name,
    Value<String?> note = const Value.absent(),
    Difficulty? difficulty,
    Value<int?> missionId = const Value.absent(),
    Value<BoardSection?> board = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> awardedXp = const Value.absent(),
    Value<int?> eventId = const Value.absent(),
  }) => QuestRow(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
    difficulty: difficulty ?? this.difficulty,
    missionId: missionId.present ? missionId.value : this.missionId,
    board: board.present ? board.value : this.board,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    awardedXp: awardedXp.present ? awardedXp.value : this.awardedXp,
    eventId: eventId.present ? eventId.value : this.eventId,
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
      board: data.board.present ? data.board.value : this.board,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      awardedXp: data.awardedXp.present ? data.awardedXp.value : this.awardedXp,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
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
          ..write('board: $board, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedXp: $awardedXp, ')
          ..write('eventId: $eventId')
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
    board,
    sortOrder,
    createdAt,
    completedAt,
    awardedXp,
    eventId,
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
          other.board == this.board &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.awardedXp == this.awardedXp &&
          other.eventId == this.eventId);
}

class QuestsCompanion extends UpdateCompanion<QuestRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> note;
  final Value<Difficulty> difficulty;
  final Value<int?> missionId;
  final Value<BoardSection?> board;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int?> awardedXp;
  final Value<int?> eventId;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.missionId = const Value.absent(),
    this.board = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.awardedXp = const Value.absent(),
    this.eventId = const Value.absent(),
  });
  QuestsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
    required Difficulty difficulty,
    this.missionId = const Value.absent(),
    this.board = const Value.absent(),
    required int sortOrder,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.awardedXp = const Value.absent(),
    this.eventId = const Value.absent(),
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
    Expression<String>? board,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? awardedXp,
    Expression<int>? eventId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (difficulty != null) 'difficulty': difficulty,
      if (missionId != null) 'mission_id': missionId,
      if (board != null) 'board': board,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (awardedXp != null) 'awarded_xp': awardedXp,
      if (eventId != null) 'event_id': eventId,
    });
  }

  QuestsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? note,
    Value<Difficulty>? difficulty,
    Value<int?>? missionId,
    Value<BoardSection?>? board,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int?>? awardedXp,
    Value<int?>? eventId,
  }) {
    return QuestsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      difficulty: difficulty ?? this.difficulty,
      missionId: missionId ?? this.missionId,
      board: board ?? this.board,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      awardedXp: awardedXp ?? this.awardedXp,
      eventId: eventId ?? this.eventId,
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
    if (board.present) {
      map['board'] = Variable<String>(
        $QuestsTable.$converterboardn.toSql(board.value),
      );
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
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
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
          ..write('board: $board, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedXp: $awardedXp, ')
          ..write('eventId: $eventId')
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
  static const VerificationMeta _displayFontMeta = const VerificationMeta(
    'displayFont',
  );
  @override
  late final GeneratedColumn<String> displayFont = GeneratedColumn<String>(
    'display_font',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('figtree'),
  );
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
    if (data.containsKey('display_font')) {
      context.handle(
        _displayFontMeta,
        displayFont.isAcceptableOrUnknown(
          data['display_font']!,
          _displayFontMeta,
        ),
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
      displayFont: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_font'],
      )!,
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
}

class AppStateRow extends DataClass implements Insertable<AppStateRow> {
  final int id;
  final int totalXp;
  final String heroName;
  final AppLanguage language;
  final AppTheme theme;
  final String displayFont;
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
    map['display_font'] = Variable<String>(displayFont);
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
      displayFont: serializer.fromJson<String>(json['displayFont']),
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
      'displayFont': serializer.toJson<String>(displayFont),
    };
  }

  AppStateRow copyWith({
    int? id,
    int? totalXp,
    String? heroName,
    AppLanguage? language,
    AppTheme? theme,
    String? displayFont,
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
  final Value<String> displayFont;
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
    Value<String>? displayFont,
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
      map['display_font'] = Variable<String>(displayFont.value);
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

class $CalendarSkippedDatesTable extends CalendarSkippedDates
    with TableInfo<$CalendarSkippedDatesTable, CalendarSkippedDateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarSkippedDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_events (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> skippedOn =
      GeneratedColumn<String>(
        'skipped_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CalendarSkippedDatesTable.$converterskippedOn);
  @override
  List<GeneratedColumn> get $columns => [eventId, skippedOn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_skipped_dates';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarSkippedDateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, skippedOn};
  @override
  CalendarSkippedDateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarSkippedDateRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      skippedOn: $CalendarSkippedDatesTable.$converterskippedOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}skipped_on'],
        )!,
      ),
    );
  }

  @override
  $CalendarSkippedDatesTable createAlias(String alias) {
    return $CalendarSkippedDatesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterskippedOn =
      const DateOnlyConverter();
}

class CalendarSkippedDateRow extends DataClass
    implements Insertable<CalendarSkippedDateRow> {
  final int eventId;
  final DateTime skippedOn;
  const CalendarSkippedDateRow({
    required this.eventId,
    required this.skippedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<int>(eventId);
    {
      map['skipped_on'] = Variable<String>(
        $CalendarSkippedDatesTable.$converterskippedOn.toSql(skippedOn),
      );
    }
    return map;
  }

  CalendarSkippedDatesCompanion toCompanion(bool nullToAbsent) {
    return CalendarSkippedDatesCompanion(
      eventId: Value(eventId),
      skippedOn: Value(skippedOn),
    );
  }

  factory CalendarSkippedDateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarSkippedDateRow(
      eventId: serializer.fromJson<int>(json['eventId']),
      skippedOn: serializer.fromJson<DateTime>(json['skippedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<int>(eventId),
      'skippedOn': serializer.toJson<DateTime>(skippedOn),
    };
  }

  CalendarSkippedDateRow copyWith({int? eventId, DateTime? skippedOn}) =>
      CalendarSkippedDateRow(
        eventId: eventId ?? this.eventId,
        skippedOn: skippedOn ?? this.skippedOn,
      );
  CalendarSkippedDateRow copyWithCompanion(CalendarSkippedDatesCompanion data) {
    return CalendarSkippedDateRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      skippedOn: data.skippedOn.present ? data.skippedOn.value : this.skippedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarSkippedDateRow(')
          ..write('eventId: $eventId, ')
          ..write('skippedOn: $skippedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, skippedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarSkippedDateRow &&
          other.eventId == this.eventId &&
          other.skippedOn == this.skippedOn);
}

class CalendarSkippedDatesCompanion
    extends UpdateCompanion<CalendarSkippedDateRow> {
  final Value<int> eventId;
  final Value<DateTime> skippedOn;
  final Value<int> rowid;
  const CalendarSkippedDatesCompanion({
    this.eventId = const Value.absent(),
    this.skippedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarSkippedDatesCompanion.insert({
    required int eventId,
    required DateTime skippedOn,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       skippedOn = Value(skippedOn);
  static Insertable<CalendarSkippedDateRow> custom({
    Expression<int>? eventId,
    Expression<String>? skippedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (skippedOn != null) 'skipped_on': skippedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarSkippedDatesCompanion copyWith({
    Value<int>? eventId,
    Value<DateTime>? skippedOn,
    Value<int>? rowid,
  }) {
    return CalendarSkippedDatesCompanion(
      eventId: eventId ?? this.eventId,
      skippedOn: skippedOn ?? this.skippedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (skippedOn.present) {
      map['skipped_on'] = Variable<String>(
        $CalendarSkippedDatesTable.$converterskippedOn.toSql(skippedOn.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarSkippedDatesCompanion(')
          ..write('eventId: $eventId, ')
          ..write('skippedOn: $skippedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarCompletionsTable extends CalendarCompletions
    with TableInfo<$CalendarCompletionsTable, CalendarCompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_events (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> occurrenceDate =
      GeneratedColumn<String>(
        'occurrence_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $CalendarCompletionsTable.$converteroccurrenceDate,
      );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awardedXpMeta = const VerificationMeta(
    'awardedXp',
  );
  @override
  late final GeneratedColumn<int> awardedXp = GeneratedColumn<int>(
    'awarded_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    occurrenceDate,
    completedAt,
    awardedXp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarCompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('awarded_xp')) {
      context.handle(
        _awardedXpMeta,
        awardedXp.isAcceptableOrUnknown(data['awarded_xp']!, _awardedXpMeta),
      );
    } else if (isInserting) {
      context.missing(_awardedXpMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, occurrenceDate};
  @override
  CalendarCompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarCompletionRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      occurrenceDate: $CalendarCompletionsTable.$converteroccurrenceDate
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}occurrence_date'],
            )!,
          ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      awardedXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awarded_xp'],
      )!,
    );
  }

  @override
  $CalendarCompletionsTable createAlias(String alias) {
    return $CalendarCompletionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converteroccurrenceDate =
      const DateOnlyConverter();
}

class CalendarCompletionRow extends DataClass
    implements Insertable<CalendarCompletionRow> {
  final int eventId;
  final DateTime occurrenceDate;
  final DateTime completedAt;
  final int awardedXp;
  const CalendarCompletionRow({
    required this.eventId,
    required this.occurrenceDate,
    required this.completedAt,
    required this.awardedXp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<int>(eventId);
    {
      map['occurrence_date'] = Variable<String>(
        $CalendarCompletionsTable.$converteroccurrenceDate.toSql(
          occurrenceDate,
        ),
      );
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['awarded_xp'] = Variable<int>(awardedXp);
    return map;
  }

  CalendarCompletionsCompanion toCompanion(bool nullToAbsent) {
    return CalendarCompletionsCompanion(
      eventId: Value(eventId),
      occurrenceDate: Value(occurrenceDate),
      completedAt: Value(completedAt),
      awardedXp: Value(awardedXp),
    );
  }

  factory CalendarCompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarCompletionRow(
      eventId: serializer.fromJson<int>(json['eventId']),
      occurrenceDate: serializer.fromJson<DateTime>(json['occurrenceDate']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      awardedXp: serializer.fromJson<int>(json['awardedXp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<int>(eventId),
      'occurrenceDate': serializer.toJson<DateTime>(occurrenceDate),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'awardedXp': serializer.toJson<int>(awardedXp),
    };
  }

  CalendarCompletionRow copyWith({
    int? eventId,
    DateTime? occurrenceDate,
    DateTime? completedAt,
    int? awardedXp,
  }) => CalendarCompletionRow(
    eventId: eventId ?? this.eventId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    completedAt: completedAt ?? this.completedAt,
    awardedXp: awardedXp ?? this.awardedXp,
  );
  CalendarCompletionRow copyWithCompanion(CalendarCompletionsCompanion data) {
    return CalendarCompletionRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      awardedXp: data.awardedXp.present ? data.awardedXp.value : this.awardedXp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarCompletionRow(')
          ..write('eventId: $eventId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedXp: $awardedXp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(eventId, occurrenceDate, completedAt, awardedXp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarCompletionRow &&
          other.eventId == this.eventId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.completedAt == this.completedAt &&
          other.awardedXp == this.awardedXp);
}

class CalendarCompletionsCompanion
    extends UpdateCompanion<CalendarCompletionRow> {
  final Value<int> eventId;
  final Value<DateTime> occurrenceDate;
  final Value<DateTime> completedAt;
  final Value<int> awardedXp;
  final Value<int> rowid;
  const CalendarCompletionsCompanion({
    this.eventId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.awardedXp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarCompletionsCompanion.insert({
    required int eventId,
    required DateTime occurrenceDate,
    required DateTime completedAt,
    required int awardedXp,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       occurrenceDate = Value(occurrenceDate),
       completedAt = Value(completedAt),
       awardedXp = Value(awardedXp);
  static Insertable<CalendarCompletionRow> custom({
    Expression<int>? eventId,
    Expression<String>? occurrenceDate,
    Expression<DateTime>? completedAt,
    Expression<int>? awardedXp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (awardedXp != null) 'awarded_xp': awardedXp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarCompletionsCompanion copyWith({
    Value<int>? eventId,
    Value<DateTime>? occurrenceDate,
    Value<DateTime>? completedAt,
    Value<int>? awardedXp,
    Value<int>? rowid,
  }) {
    return CalendarCompletionsCompanion(
      eventId: eventId ?? this.eventId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      completedAt: completedAt ?? this.completedAt,
      awardedXp: awardedXp ?? this.awardedXp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<String>(
        $CalendarCompletionsTable.$converteroccurrenceDate.toSql(
          occurrenceDate.value,
        ),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (awardedXp.present) {
      map['awarded_xp'] = Variable<int>(awardedXp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarCompletionsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('awardedXp: $awardedXp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarAddressesTable extends CalendarAddresses
    with TableInfo<$CalendarAddressesTable, CalendarAddressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    check: () => ComparableExpr(address.length).isBetweenValues(1, 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, address, lastUsedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_addresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarAddressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CalendarAddressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarAddressRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $CalendarAddressesTable createAlias(String alias) {
    return $CalendarAddressesTable(attachedDatabase, alias);
  }
}

class CalendarAddressRow extends DataClass
    implements Insertable<CalendarAddressRow> {
  final String key;
  final String address;
  final DateTime lastUsedAt;
  const CalendarAddressRow({
    required this.key,
    required this.address,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['address'] = Variable<String>(address);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  CalendarAddressesCompanion toCompanion(bool nullToAbsent) {
    return CalendarAddressesCompanion(
      key: Value(key),
      address: Value(address),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory CalendarAddressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarAddressRow(
      key: serializer.fromJson<String>(json['key']),
      address: serializer.fromJson<String>(json['address']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'address': serializer.toJson<String>(address),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  CalendarAddressRow copyWith({
    String? key,
    String? address,
    DateTime? lastUsedAt,
  }) => CalendarAddressRow(
    key: key ?? this.key,
    address: address ?? this.address,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  CalendarAddressRow copyWithCompanion(CalendarAddressesCompanion data) {
    return CalendarAddressRow(
      key: data.key.present ? data.key.value : this.key,
      address: data.address.present ? data.address.value : this.address,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarAddressRow(')
          ..write('key: $key, ')
          ..write('address: $address, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, address, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarAddressRow &&
          other.key == this.key &&
          other.address == this.address &&
          other.lastUsedAt == this.lastUsedAt);
}

class CalendarAddressesCompanion extends UpdateCompanion<CalendarAddressRow> {
  final Value<String> key;
  final Value<String> address;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const CalendarAddressesCompanion({
    this.key = const Value.absent(),
    this.address = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarAddressesCompanion.insert({
    required String key,
    required String address,
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       address = Value(address),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<CalendarAddressRow> custom({
    Expression<String>? key,
    Expression<String>? address,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (address != null) 'address': address,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarAddressesCompanion copyWith({
    Value<String>? key,
    Value<String>? address,
    Value<DateTime>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return CalendarAddressesCompanion(
      key: key ?? this.key,
      address: address ?? this.address,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarAddressesCompanion(')
          ..write('key: $key, ')
          ..write('address: $address, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteNodesTable extends NoteNodes
    with TableInfo<$NoteNodesTable, NoteNodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteNodesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES note_nodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _isFolderMeta = const VerificationMeta(
    'isFolder',
  );
  @override
  late final GeneratedColumn<bool> isFolder = GeneratedColumn<bool>(
    'is_folder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_folder" IN (0, 1))',
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    check: () => ComparableExpr(body.length).isSmallerOrEqualValue(100000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _autoNameMeta = const VerificationMeta(
    'autoName',
  );
  @override
  late final GeneratedColumn<bool> autoName = GeneratedColumn<bool>(
    'auto_name',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_name" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    isFolder,
    name,
    body,
    autoName,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteNodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('is_folder')) {
      context.handle(
        _isFolderMeta,
        isFolder.isAcceptableOrUnknown(data['is_folder']!, _isFolderMeta),
      );
    } else if (isInserting) {
      context.missing(_isFolderMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('auto_name')) {
      context.handle(
        _autoNameMeta,
        autoName.isAcceptableOrUnknown(data['auto_name']!, _autoNameMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteNodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteNodeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      isFolder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_folder'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      autoName: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $NoteNodesTable createAlias(String alias) {
    return $NoteNodesTable(attachedDatabase, alias);
  }
}

class NoteNodeRow extends DataClass implements Insertable<NoteNodeRow> {
  final int id;
  final int? parentId;
  final bool isFolder;
  final String name;

  /// The Markdown_Body; always empty for a Folder.
  final String body;
  final bool autoName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const NoteNodeRow({
    required this.id,
    this.parentId,
    required this.isFolder,
    required this.name,
    required this.body,
    required this.autoName,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['is_folder'] = Variable<bool>(isFolder);
    map['name'] = Variable<String>(name);
    map['body'] = Variable<String>(body);
    map['auto_name'] = Variable<bool>(autoName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  NoteNodesCompanion toCompanion(bool nullToAbsent) {
    return NoteNodesCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isFolder: Value(isFolder),
      name: Value(name),
      body: Value(body),
      autoName: Value(autoName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory NoteNodeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteNodeRow(
      id: serializer.fromJson<int>(json['id']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      isFolder: serializer.fromJson<bool>(json['isFolder']),
      name: serializer.fromJson<String>(json['name']),
      body: serializer.fromJson<String>(json['body']),
      autoName: serializer.fromJson<bool>(json['autoName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'parentId': serializer.toJson<int?>(parentId),
      'isFolder': serializer.toJson<bool>(isFolder),
      'name': serializer.toJson<String>(name),
      'body': serializer.toJson<String>(body),
      'autoName': serializer.toJson<bool>(autoName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  NoteNodeRow copyWith({
    int? id,
    Value<int?> parentId = const Value.absent(),
    bool? isFolder,
    String? name,
    String? body,
    bool? autoName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => NoteNodeRow(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    isFolder: isFolder ?? this.isFolder,
    name: name ?? this.name,
    body: body ?? this.body,
    autoName: autoName ?? this.autoName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  NoteNodeRow copyWithCompanion(NoteNodesCompanion data) {
    return NoteNodeRow(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isFolder: data.isFolder.present ? data.isFolder.value : this.isFolder,
      name: data.name.present ? data.name.value : this.name,
      body: data.body.present ? data.body.value : this.body,
      autoName: data.autoName.present ? data.autoName.value : this.autoName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteNodeRow(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('isFolder: $isFolder, ')
          ..write('name: $name, ')
          ..write('body: $body, ')
          ..write('autoName: $autoName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    isFolder,
    name,
    body,
    autoName,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteNodeRow &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.isFolder == this.isFolder &&
          other.name == this.name &&
          other.body == this.body &&
          other.autoName == this.autoName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class NoteNodesCompanion extends UpdateCompanion<NoteNodeRow> {
  final Value<int> id;
  final Value<int?> parentId;
  final Value<bool> isFolder;
  final Value<String> name;
  final Value<String> body;
  final Value<bool> autoName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const NoteNodesCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isFolder = const Value.absent(),
    this.name = const Value.absent(),
    this.body = const Value.absent(),
    this.autoName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  NoteNodesCompanion.insert({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    required bool isFolder,
    required String name,
    this.body = const Value.absent(),
    this.autoName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : isFolder = Value(isFolder),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteNodeRow> custom({
    Expression<int>? id,
    Expression<int>? parentId,
    Expression<bool>? isFolder,
    Expression<String>? name,
    Expression<String>? body,
    Expression<bool>? autoName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (isFolder != null) 'is_folder': isFolder,
      if (name != null) 'name': name,
      if (body != null) 'body': body,
      if (autoName != null) 'auto_name': autoName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  NoteNodesCompanion copyWith({
    Value<int>? id,
    Value<int?>? parentId,
    Value<bool>? isFolder,
    Value<String>? name,
    Value<String>? body,
    Value<bool>? autoName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return NoteNodesCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      isFolder: isFolder ?? this.isFolder,
      name: name ?? this.name,
      body: body ?? this.body,
      autoName: autoName ?? this.autoName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (isFolder.present) {
      map['is_folder'] = Variable<bool>(isFolder.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (autoName.present) {
      map['auto_name'] = Variable<bool>(autoName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteNodesCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('isFolder: $isFolder, ')
          ..write('name: $name, ')
          ..write('body: $body, ')
          ..write('autoName: $autoName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$QuestlogDatabase extends GeneratedDatabase {
  _$QuestlogDatabase(QueryExecutor e) : super(e);
  $QuestlogDatabaseManager get managers => $QuestlogDatabaseManager(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $MissionsTable missions = $MissionsTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $RuleQuestsTable ruleQuests = $RuleQuestsTable(this);
  late final $AppStateTable appState = $AppStateTable(this);
  late final $CalendarSkippedDatesTable calendarSkippedDates =
      $CalendarSkippedDatesTable(this);
  late final $CalendarCompletionsTable calendarCompletions =
      $CalendarCompletionsTable(this);
  late final $CalendarAddressesTable calendarAddresses =
      $CalendarAddressesTable(this);
  late final $NoteNodesTable noteNodes = $NoteNodesTable(this);
  late final Index idxQuestsMission = Index(
    'idx_quests_mission',
    'CREATE INDEX idx_quests_mission ON quests (mission_id)',
  );
  late final Index idxQuestsCompleted = Index(
    'idx_quests_completed',
    'CREATE INDEX idx_quests_completed ON quests (completed_at)',
  );
  late final Index idxCalendarEventsStart = Index(
    'idx_calendar_events_start',
    'CREATE INDEX idx_calendar_events_start ON calendar_events (start_date)',
  );
  late final Index idxNoteNodesParent = Index(
    'idx_note_nodes_parent',
    'CREATE INDEX idx_note_nodes_parent ON note_nodes (parent_id)',
  );
  late final Index idxNoteNodesDeleted = Index(
    'idx_note_nodes_deleted',
    'CREATE INDEX idx_note_nodes_deleted ON note_nodes (deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recurringRules,
    missions,
    calendarEvents,
    quests,
    ruleQuests,
    appState,
    calendarSkippedDates,
    calendarCompletions,
    calendarAddresses,
    noteNodes,
    idxQuestsMission,
    idxQuestsCompleted,
    idxCalendarEventsStart,
    idxNoteNodesParent,
    idxNoteNodesDeleted,
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
        'calendar_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quests', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rule_quests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'calendar_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('calendar_skipped_dates', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'calendar_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('calendar_completions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'note_nodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_nodes', kind: UpdateKind.delete)],
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
  Value<int> sortOrder,
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
  Value<int> sortOrder,
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

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
                Value<int> sortOrder = const Value.absent(),
                Value<int?> awardedBonus = const Value.absent(),
                Value<int?> ruleId = const Value.absent(),
              }) => MissionsCompanion(
                id: id,
                name: name,
                bonus: bonus,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                sortOrder: sortOrder,
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
                Value<int> sortOrder = const Value.absent(),
                Value<int?> awardedBonus = const Value.absent(),
                Value<int?> ruleId = const Value.absent(),
              }) => MissionsCompanion.insert(
                id: id,
                name: name,
                bonus: bonus,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                sortOrder: sortOrder,
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
typedef $$CalendarEventsTableCreateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> note,
      Value<String?> location,
      required String eventType,
      required DateTime startDate,
      required DateTime endDate,
      Value<int?> startMinute,
      Value<int?> endMinute,
      Value<String> repeatKind,
      Value<int?> easterOffset,
      Value<int?> nthMonth,
      Value<int?> nthWeekday,
      Value<int?> nthOrdinal,
      Value<DateTime?> repeatEnd,
      Value<bool> onBoard,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CalendarEventsTableUpdateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> note,
      Value<String?> location,
      Value<String> eventType,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<int?> startMinute,
      Value<int?> endMinute,
      Value<String> repeatKind,
      Value<int?> easterOffset,
      Value<int?> nthMonth,
      Value<int?> nthWeekday,
      Value<int?> nthOrdinal,
      Value<DateTime?> repeatEnd,
      Value<bool> onBoard,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CalendarEventsTableReferences
    extends
        BaseReferences<
          _$QuestlogDatabase,
          $CalendarEventsTable,
          CalendarEventRow
        > {
  $$CalendarEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$QuestsTable, List<QuestRow>> _questsRefsTable(
    _$QuestlogDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quests,
    aliasName: 'calendar_events__id__quests__event_id',
  );

  $$QuestsTableProcessedTableManager get questsRefs {
    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_questsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CalendarSkippedDatesTable,
    List<CalendarSkippedDateRow>
  >
  _calendarSkippedDatesRefsTable(_$QuestlogDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.calendarSkippedDates,
        aliasName: 'calendar_events__id__calendar_skipped_dates__event_id',
      );

  $$CalendarSkippedDatesTableProcessedTableManager
  get calendarSkippedDatesRefs {
    final manager = $$CalendarSkippedDatesTableTableManager(
      $_db,
      $_db.calendarSkippedDates,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _calendarSkippedDatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CalendarCompletionsTable,
    List<CalendarCompletionRow>
  >
  _calendarCompletionsRefsTable(_$QuestlogDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.calendarCompletions,
        aliasName: 'calendar_events__id__calendar_completions__event_id',
      );

  $$CalendarCompletionsTableProcessedTableManager get calendarCompletionsRefs {
    final manager = $$CalendarCompletionsTableTableManager(
      $_db,
      $_db.calendarCompletions,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _calendarCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CalendarEventsTableFilterComposer
    extends Composer<_$QuestlogDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
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

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get endDate =>
      $composableBuilder(
        column: $table.endDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatKind => $composableBuilder(
    column: $table.repeatKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get easterOffset => $composableBuilder(
    column: $table.easterOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nthMonth => $composableBuilder(
    column: $table.nthMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nthWeekday => $composableBuilder(
    column: $table.nthWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nthOrdinal => $composableBuilder(
    column: $table.nthOrdinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get repeatEnd =>
      $composableBuilder(
        column: $table.repeatEnd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get onBoard => $composableBuilder(
    column: $table.onBoard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questsRefs(
    Expression<bool> Function($$QuestsTableFilterComposer f) f,
  ) {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.eventId,
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

  Expression<bool> calendarSkippedDatesRefs(
    Expression<bool> Function($$CalendarSkippedDatesTableFilterComposer f) f,
  ) {
    final $$CalendarSkippedDatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarSkippedDates,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarSkippedDatesTableFilterComposer(
            $db: $db,
            $table: $db.calendarSkippedDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> calendarCompletionsRefs(
    Expression<bool> Function($$CalendarCompletionsTableFilterComposer f) f,
  ) {
    final $$CalendarCompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarCompletions,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarCompletionsTableFilterComposer(
            $db: $db,
            $table: $db.calendarCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
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

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatKind => $composableBuilder(
    column: $table.repeatKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get easterOffset => $composableBuilder(
    column: $table.easterOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nthMonth => $composableBuilder(
    column: $table.nthMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nthWeekday => $composableBuilder(
    column: $table.nthWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nthOrdinal => $composableBuilder(
    column: $table.nthOrdinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatEnd => $composableBuilder(
    column: $table.repeatEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onBoard => $composableBuilder(
    column: $table.onBoard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<String> get repeatKind => $composableBuilder(
    column: $table.repeatKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get easterOffset => $composableBuilder(
    column: $table.easterOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nthMonth =>
      $composableBuilder(column: $table.nthMonth, builder: (column) => column);

  GeneratedColumn<int> get nthWeekday => $composableBuilder(
    column: $table.nthWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nthOrdinal => $composableBuilder(
    column: $table.nthOrdinal,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get repeatEnd =>
      $composableBuilder(column: $table.repeatEnd, builder: (column) => column);

  GeneratedColumn<bool> get onBoard =>
      $composableBuilder(column: $table.onBoard, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> questsRefs<T extends Object>(
    Expression<T> Function($$QuestsTableAnnotationComposer a) f,
  ) {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.eventId,
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

  Expression<T> calendarSkippedDatesRefs<T extends Object>(
    Expression<T> Function($$CalendarSkippedDatesTableAnnotationComposer a) f,
  ) {
    final $$CalendarSkippedDatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.calendarSkippedDates,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CalendarSkippedDatesTableAnnotationComposer(
                $db: $db,
                $table: $db.calendarSkippedDates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> calendarCompletionsRefs<T extends Object>(
    Expression<T> Function($$CalendarCompletionsTableAnnotationComposer a) f,
  ) {
    final $$CalendarCompletionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.calendarCompletions,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CalendarCompletionsTableAnnotationComposer(
                $db: $db,
                $table: $db.calendarCompletions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CalendarEventsTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $CalendarEventsTable,
          CalendarEventRow,
          $$CalendarEventsTableFilterComposer,
          $$CalendarEventsTableOrderingComposer,
          $$CalendarEventsTableAnnotationComposer,
          $$CalendarEventsTableCreateCompanionBuilder,
          $$CalendarEventsTableUpdateCompanionBuilder,
          (CalendarEventRow, $$CalendarEventsTableReferences),
          CalendarEventRow,
          PrefetchHooks Function({
            bool questsRefs,
            bool calendarSkippedDatesRefs,
            bool calendarCompletionsRefs,
          })
        > {
  $$CalendarEventsTableTableManager(
    _$QuestlogDatabase db,
    $CalendarEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
                Value<int?> endMinute = const Value.absent(),
                Value<String> repeatKind = const Value.absent(),
                Value<int?> easterOffset = const Value.absent(),
                Value<int?> nthMonth = const Value.absent(),
                Value<int?> nthWeekday = const Value.absent(),
                Value<int?> nthOrdinal = const Value.absent(),
                Value<DateTime?> repeatEnd = const Value.absent(),
                Value<bool> onBoard = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CalendarEventsCompanion(
                id: id,
                name: name,
                note: note,
                location: location,
                eventType: eventType,
                startDate: startDate,
                endDate: endDate,
                startMinute: startMinute,
                endMinute: endMinute,
                repeatKind: repeatKind,
                easterOffset: easterOffset,
                nthMonth: nthMonth,
                nthWeekday: nthWeekday,
                nthOrdinal: nthOrdinal,
                repeatEnd: repeatEnd,
                onBoard: onBoard,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> note = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required String eventType,
                required DateTime startDate,
                required DateTime endDate,
                Value<int?> startMinute = const Value.absent(),
                Value<int?> endMinute = const Value.absent(),
                Value<String> repeatKind = const Value.absent(),
                Value<int?> easterOffset = const Value.absent(),
                Value<int?> nthMonth = const Value.absent(),
                Value<int?> nthWeekday = const Value.absent(),
                Value<int?> nthOrdinal = const Value.absent(),
                Value<DateTime?> repeatEnd = const Value.absent(),
                Value<bool> onBoard = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CalendarEventsCompanion.insert(
                id: id,
                name: name,
                note: note,
                location: location,
                eventType: eventType,
                startDate: startDate,
                endDate: endDate,
                startMinute: startMinute,
                endMinute: endMinute,
                repeatKind: repeatKind,
                easterOffset: easterOffset,
                nthMonth: nthMonth,
                nthWeekday: nthWeekday,
                nthOrdinal: nthOrdinal,
                repeatEnd: repeatEnd,
                onBoard: onBoard,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarEventsTable, CalendarEventRow>(table),
                  $$CalendarEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                questsRefs = false,
                calendarSkippedDatesRefs = false,
                calendarCompletionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (questsRefs) db.quests,
                    if (calendarSkippedDatesRefs) db.calendarSkippedDates,
                    if (calendarCompletionsRefs) db.calendarCompletions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (questsRefs)
                        await $_getPrefetchedDataByColumns<
                          CalendarEventRow,
                          $CalendarEventsTable,
                          QuestRow,
                          $QuestsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CalendarEventsTableReferences
                              ._questsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CalendarEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).questsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'event_id',
                          typedResults: items,
                        ),
                      if (calendarSkippedDatesRefs)
                        await $_getPrefetchedDataByColumns<
                          CalendarEventRow,
                          $CalendarEventsTable,
                          CalendarSkippedDateRow,
                          $CalendarSkippedDatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CalendarEventsTableReferences
                              ._calendarSkippedDatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CalendarEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarSkippedDatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'event_id',
                          typedResults: items,
                        ),
                      if (calendarCompletionsRefs)
                        await $_getPrefetchedDataByColumns<
                          CalendarEventRow,
                          $CalendarEventsTable,
                          CalendarCompletionRow,
                          $CalendarCompletionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CalendarEventsTableReferences
                              ._calendarCompletionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CalendarEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarCompletionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'event_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CalendarEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $CalendarEventsTable,
      CalendarEventRow,
      $$CalendarEventsTableFilterComposer,
      $$CalendarEventsTableOrderingComposer,
      $$CalendarEventsTableAnnotationComposer,
      $$CalendarEventsTableCreateCompanionBuilder,
      $$CalendarEventsTableUpdateCompanionBuilder,
      (CalendarEventRow, $$CalendarEventsTableReferences),
      CalendarEventRow,
      PrefetchHooks Function({
        bool questsRefs,
        bool calendarSkippedDatesRefs,
        bool calendarCompletionsRefs,
      })
    >;
typedef $$QuestsTableCreateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> note,
  required Difficulty difficulty,
  Value<int?> missionId,
  Value<BoardSection?> board,
  required int sortOrder,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int?> awardedXp,
  Value<int?> eventId,
});
typedef $$QuestsTableUpdateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> note,
  Value<Difficulty> difficulty,
  Value<int?> missionId,
  Value<BoardSection?> board,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> awardedXp,
  Value<int?> eventId,
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

  static $CalendarEventsTable _eventIdTable(_$QuestlogDatabase db) =>
      db.calendarEvents.createAlias('quests__event_id__calendar_events__id');

  $$CalendarEventsTableProcessedTableManager? get eventId {
    final $_column = $_itemColumn<int>('event_id');
    if ($_column == null) return null;
    final manager = $$CalendarEventsTableTableManager(
      $_db,
      $_db.calendarEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
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

  ColumnWithTypeConverterFilters<BoardSection?, BoardSection, String>
  get board => $composableBuilder(
    column: $table.board,
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

  $$CalendarEventsTableFilterComposer get eventId {
    final $$CalendarEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableFilterComposer(
            $db: $db,
            $table: $db.calendarEvents,
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

  ColumnOrderings<String> get board => $composableBuilder(
    column: $table.board,
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

  $$CalendarEventsTableOrderingComposer get eventId {
    final $$CalendarEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableOrderingComposer(
            $db: $db,
            $table: $db.calendarEvents,
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

  GeneratedColumnWithTypeConverter<BoardSection?, String> get board =>
      $composableBuilder(column: $table.board, builder: (column) => column);

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

  $$CalendarEventsTableAnnotationComposer get eventId {
    final $$CalendarEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarEvents,
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
          PrefetchHooks Function({bool missionId, bool eventId})
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
                Value<BoardSection?> board = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> awardedXp = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
              }) => QuestsCompanion(
                id: id,
                name: name,
                note: note,
                difficulty: difficulty,
                missionId: missionId,
                board: board,
                sortOrder: sortOrder,
                createdAt: createdAt,
                completedAt: completedAt,
                awardedXp: awardedXp,
                eventId: eventId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> note = const Value.absent(),
                required Difficulty difficulty,
                Value<int?> missionId = const Value.absent(),
                Value<BoardSection?> board = const Value.absent(),
                required int sortOrder,
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> awardedXp = const Value.absent(),
                Value<int?> eventId = const Value.absent(),
              }) => QuestsCompanion.insert(
                id: id,
                name: name,
                note: note,
                difficulty: difficulty,
                missionId: missionId,
                board: board,
                sortOrder: sortOrder,
                createdAt: createdAt,
                completedAt: completedAt,
                awardedXp: awardedXp,
                eventId: eventId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestsTable, QuestRow>(table),
                  $$QuestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({missionId = false, eventId = false}) {
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
                    if (eventId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.eventId,
                        referencedTable: $$QuestsTableReferences._eventIdTable(
                          db,
                        ),
                        referencedColumn: $$QuestsTableReferences
                            ._eventIdTable(db)
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
      PrefetchHooks Function({bool missionId, bool eventId})
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
  Value<String> displayFont,
});
typedef $$AppStateTableUpdateCompanionBuilder = AppStateCompanion Function({
  Value<int> id,
  Value<int> totalXp,
  Value<String> heroName,
  Value<AppLanguage> language,
  Value<AppTheme> theme,
  Value<String> displayFont,
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

  ColumnFilters<String> get displayFont => $composableBuilder(
    column: $table.displayFont,
    builder: (column) => ColumnFilters(column),
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

  GeneratedColumn<String> get displayFont => $composableBuilder(
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
                Value<String> displayFont = const Value.absent(),
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
                Value<String> displayFont = const Value.absent(),
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
typedef $$CalendarSkippedDatesTableCreateCompanionBuilder =
    CalendarSkippedDatesCompanion Function({
      required int eventId,
      required DateTime skippedOn,
      Value<int> rowid,
    });
typedef $$CalendarSkippedDatesTableUpdateCompanionBuilder =
    CalendarSkippedDatesCompanion Function({
      Value<int> eventId,
      Value<DateTime> skippedOn,
      Value<int> rowid,
    });

final class $$CalendarSkippedDatesTableReferences
    extends
        BaseReferences<
          _$QuestlogDatabase,
          $CalendarSkippedDatesTable,
          CalendarSkippedDateRow
        > {
  $$CalendarSkippedDatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CalendarEventsTable _eventIdTable(_$QuestlogDatabase db) => db
      .calendarEvents
      .createAlias('calendar_skipped_dates__event_id__calendar_events__id');

  $$CalendarEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$CalendarEventsTableTableManager(
      $_db,
      $_db.calendarEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CalendarSkippedDatesTableFilterComposer
    extends Composer<_$QuestlogDatabase, $CalendarSkippedDatesTable> {
  $$CalendarSkippedDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get skippedOn =>
      $composableBuilder(
        column: $table.skippedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CalendarEventsTableFilterComposer get eventId {
    final $$CalendarEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableFilterComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarSkippedDatesTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $CalendarSkippedDatesTable> {
  $$CalendarSkippedDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get skippedOn => $composableBuilder(
    column: $table.skippedOn,
    builder: (column) => ColumnOrderings(column),
  );

  $$CalendarEventsTableOrderingComposer get eventId {
    final $$CalendarEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableOrderingComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarSkippedDatesTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $CalendarSkippedDatesTable> {
  $$CalendarSkippedDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateTime, String> get skippedOn =>
      $composableBuilder(column: $table.skippedOn, builder: (column) => column);

  $$CalendarEventsTableAnnotationComposer get eventId {
    final $$CalendarEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarSkippedDatesTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $CalendarSkippedDatesTable,
          CalendarSkippedDateRow,
          $$CalendarSkippedDatesTableFilterComposer,
          $$CalendarSkippedDatesTableOrderingComposer,
          $$CalendarSkippedDatesTableAnnotationComposer,
          $$CalendarSkippedDatesTableCreateCompanionBuilder,
          $$CalendarSkippedDatesTableUpdateCompanionBuilder,
          (CalendarSkippedDateRow, $$CalendarSkippedDatesTableReferences),
          CalendarSkippedDateRow,
          PrefetchHooks Function({bool eventId})
        > {
  $$CalendarSkippedDatesTableTableManager(
    _$QuestlogDatabase db,
    $CalendarSkippedDatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarSkippedDatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarSkippedDatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CalendarSkippedDatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> eventId = const Value.absent(),
                Value<DateTime> skippedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarSkippedDatesCompanion(
                eventId: eventId,
                skippedOn: skippedOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int eventId,
                required DateTime skippedOn,
                Value<int> rowid = const Value.absent(),
              }) => CalendarSkippedDatesCompanion.insert(
                eventId: eventId,
                skippedOn: skippedOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CalendarSkippedDatesTable,
                    CalendarSkippedDateRow
                  >(table),
                  $$CalendarSkippedDatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
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
                    if (eventId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.eventId,
                        referencedTable: $$CalendarSkippedDatesTableReferences
                            ._eventIdTable(db),
                        referencedColumn: $$CalendarSkippedDatesTableReferences
                            ._eventIdTable(db)
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

typedef $$CalendarSkippedDatesTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $CalendarSkippedDatesTable,
      CalendarSkippedDateRow,
      $$CalendarSkippedDatesTableFilterComposer,
      $$CalendarSkippedDatesTableOrderingComposer,
      $$CalendarSkippedDatesTableAnnotationComposer,
      $$CalendarSkippedDatesTableCreateCompanionBuilder,
      $$CalendarSkippedDatesTableUpdateCompanionBuilder,
      (CalendarSkippedDateRow, $$CalendarSkippedDatesTableReferences),
      CalendarSkippedDateRow,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$CalendarCompletionsTableCreateCompanionBuilder =
    CalendarCompletionsCompanion Function({
      required int eventId,
      required DateTime occurrenceDate,
      required DateTime completedAt,
      required int awardedXp,
      Value<int> rowid,
    });
typedef $$CalendarCompletionsTableUpdateCompanionBuilder =
    CalendarCompletionsCompanion Function({
      Value<int> eventId,
      Value<DateTime> occurrenceDate,
      Value<DateTime> completedAt,
      Value<int> awardedXp,
      Value<int> rowid,
    });

final class $$CalendarCompletionsTableReferences
    extends
        BaseReferences<
          _$QuestlogDatabase,
          $CalendarCompletionsTable,
          CalendarCompletionRow
        > {
  $$CalendarCompletionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CalendarEventsTable _eventIdTable(_$QuestlogDatabase db) => db
      .calendarEvents
      .createAlias('calendar_completions__event_id__calendar_events__id');

  $$CalendarEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$CalendarEventsTableTableManager(
      $_db,
      $_db.calendarEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CalendarCompletionsTableFilterComposer
    extends Composer<_$QuestlogDatabase, $CalendarCompletionsTable> {
  $$CalendarCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateTime, DateTime, String>
  get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awardedXp => $composableBuilder(
    column: $table.awardedXp,
    builder: (column) => ColumnFilters(column),
  );

  $$CalendarEventsTableFilterComposer get eventId {
    final $$CalendarEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableFilterComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarCompletionsTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $CalendarCompletionsTable> {
  $$CalendarCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
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

  $$CalendarEventsTableOrderingComposer get eventId {
    final $$CalendarEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableOrderingComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarCompletionsTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $CalendarCompletionsTable> {
  $$CalendarCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateTime, String> get occurrenceDate =>
      $composableBuilder(
        column: $table.occurrenceDate,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awardedXp =>
      $composableBuilder(column: $table.awardedXp, builder: (column) => column);

  $$CalendarEventsTableAnnotationComposer get eventId {
    final $$CalendarEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarCompletionsTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $CalendarCompletionsTable,
          CalendarCompletionRow,
          $$CalendarCompletionsTableFilterComposer,
          $$CalendarCompletionsTableOrderingComposer,
          $$CalendarCompletionsTableAnnotationComposer,
          $$CalendarCompletionsTableCreateCompanionBuilder,
          $$CalendarCompletionsTableUpdateCompanionBuilder,
          (CalendarCompletionRow, $$CalendarCompletionsTableReferences),
          CalendarCompletionRow,
          PrefetchHooks Function({bool eventId})
        > {
  $$CalendarCompletionsTableTableManager(
    _$QuestlogDatabase db,
    $CalendarCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarCompletionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CalendarCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> eventId = const Value.absent(),
                Value<DateTime> occurrenceDate = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> awardedXp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarCompletionsCompanion(
                eventId: eventId,
                occurrenceDate: occurrenceDate,
                completedAt: completedAt,
                awardedXp: awardedXp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int eventId,
                required DateTime occurrenceDate,
                required DateTime completedAt,
                required int awardedXp,
                Value<int> rowid = const Value.absent(),
              }) => CalendarCompletionsCompanion.insert(
                eventId: eventId,
                occurrenceDate: occurrenceDate,
                completedAt: completedAt,
                awardedXp: awardedXp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarCompletionsTable, CalendarCompletionRow>(
                    table,
                  ),
                  $$CalendarCompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
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
                    if (eventId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.eventId,
                        referencedTable: $$CalendarCompletionsTableReferences
                            ._eventIdTable(db),
                        referencedColumn: $$CalendarCompletionsTableReferences
                            ._eventIdTable(db)
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

typedef $$CalendarCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $CalendarCompletionsTable,
      CalendarCompletionRow,
      $$CalendarCompletionsTableFilterComposer,
      $$CalendarCompletionsTableOrderingComposer,
      $$CalendarCompletionsTableAnnotationComposer,
      $$CalendarCompletionsTableCreateCompanionBuilder,
      $$CalendarCompletionsTableUpdateCompanionBuilder,
      (CalendarCompletionRow, $$CalendarCompletionsTableReferences),
      CalendarCompletionRow,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$CalendarAddressesTableCreateCompanionBuilder =
    CalendarAddressesCompanion Function({
      required String key,
      required String address,
      required DateTime lastUsedAt,
      Value<int> rowid,
    });
typedef $$CalendarAddressesTableUpdateCompanionBuilder =
    CalendarAddressesCompanion Function({
      Value<String> key,
      Value<String> address,
      Value<DateTime> lastUsedAt,
      Value<int> rowid,
    });

class $$CalendarAddressesTableFilterComposer
    extends Composer<_$QuestlogDatabase, $CalendarAddressesTable> {
  $$CalendarAddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarAddressesTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $CalendarAddressesTable> {
  $$CalendarAddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarAddressesTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $CalendarAddressesTable> {
  $$CalendarAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$CalendarAddressesTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $CalendarAddressesTable,
          CalendarAddressRow,
          $$CalendarAddressesTableFilterComposer,
          $$CalendarAddressesTableOrderingComposer,
          $$CalendarAddressesTableAnnotationComposer,
          $$CalendarAddressesTableCreateCompanionBuilder,
          $$CalendarAddressesTableUpdateCompanionBuilder,
          (
            CalendarAddressRow,
            BaseReferences<
              _$QuestlogDatabase,
              $CalendarAddressesTable,
              CalendarAddressRow
            >,
          ),
          CalendarAddressRow,
          PrefetchHooks Function()
        > {
  $$CalendarAddressesTableTableManager(
    _$QuestlogDatabase db,
    $CalendarAddressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarAddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarAddressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarAddressesCompanion(
                key: key,
                address: address,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String address,
                required DateTime lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => CalendarAddressesCompanion.insert(
                key: key,
                address: address,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarAddressesTable, CalendarAddressRow>(
                    table,
                  ),
                  BaseReferences<
                    _$QuestlogDatabase,
                    $CalendarAddressesTable,
                    CalendarAddressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarAddressesTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $CalendarAddressesTable,
      CalendarAddressRow,
      $$CalendarAddressesTableFilterComposer,
      $$CalendarAddressesTableOrderingComposer,
      $$CalendarAddressesTableAnnotationComposer,
      $$CalendarAddressesTableCreateCompanionBuilder,
      $$CalendarAddressesTableUpdateCompanionBuilder,
      (
        CalendarAddressRow,
        BaseReferences<
          _$QuestlogDatabase,
          $CalendarAddressesTable,
          CalendarAddressRow
        >,
      ),
      CalendarAddressRow,
      PrefetchHooks Function()
    >;
typedef $$NoteNodesTableCreateCompanionBuilder = NoteNodesCompanion Function({
  Value<int> id,
  Value<int?> parentId,
  required bool isFolder,
  required String name,
  Value<String> body,
  Value<bool> autoName,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$NoteNodesTableUpdateCompanionBuilder = NoteNodesCompanion Function({
  Value<int> id,
  Value<int?> parentId,
  Value<bool> isFolder,
  Value<String> name,
  Value<String> body,
  Value<bool> autoName,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

final class $$NoteNodesTableReferences
    extends BaseReferences<_$QuestlogDatabase, $NoteNodesTable, NoteNodeRow> {
  $$NoteNodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NoteNodesTable _parentIdTable(_$QuestlogDatabase db) =>
      db.noteNodes.createAlias('note_nodes__parent_id__note_nodes__id');

  $$NoteNodesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$NoteNodesTableTableManager(
      $_db,
      $_db.noteNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteNodesTableFilterComposer
    extends Composer<_$QuestlogDatabase, $NoteNodesTable> {
  $$NoteNodesTableFilterComposer({
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

  ColumnFilters<bool> get isFolder => $composableBuilder(
    column: $table.isFolder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoName => $composableBuilder(
    column: $table.autoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NoteNodesTableFilterComposer get parentId {
    final $$NoteNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.noteNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteNodesTableFilterComposer(
            $db: $db,
            $table: $db.noteNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteNodesTableOrderingComposer
    extends Composer<_$QuestlogDatabase, $NoteNodesTable> {
  $$NoteNodesTableOrderingComposer({
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

  ColumnOrderings<bool> get isFolder => $composableBuilder(
    column: $table.isFolder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoName => $composableBuilder(
    column: $table.autoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NoteNodesTableOrderingComposer get parentId {
    final $$NoteNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.noteNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteNodesTableOrderingComposer(
            $db: $db,
            $table: $db.noteNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteNodesTableAnnotationComposer
    extends Composer<_$QuestlogDatabase, $NoteNodesTable> {
  $$NoteNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isFolder =>
      $composableBuilder(column: $table.isFolder, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get autoName =>
      $composableBuilder(column: $table.autoName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$NoteNodesTableAnnotationComposer get parentId {
    final $$NoteNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.noteNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.noteNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteNodesTableTableManager
    extends
        RootTableManager<
          _$QuestlogDatabase,
          $NoteNodesTable,
          NoteNodeRow,
          $$NoteNodesTableFilterComposer,
          $$NoteNodesTableOrderingComposer,
          $$NoteNodesTableAnnotationComposer,
          $$NoteNodesTableCreateCompanionBuilder,
          $$NoteNodesTableUpdateCompanionBuilder,
          (NoteNodeRow, $$NoteNodesTableReferences),
          NoteNodeRow,
          PrefetchHooks Function({bool parentId})
        > {
  $$NoteNodesTableTableManager(_$QuestlogDatabase db, $NoteNodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<bool> isFolder = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> autoName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => NoteNodesCompanion(
                id: id,
                parentId: parentId,
                isFolder: isFolder,
                name: name,
                body: body,
                autoName: autoName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                required bool isFolder,
                required String name,
                Value<String> body = const Value.absent(),
                Value<bool> autoName = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => NoteNodesCompanion.insert(
                id: id,
                parentId: parentId,
                isFolder: isFolder,
                name: name,
                body: body,
                autoName: autoName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteNodesTable, NoteNodeRow>(table),
                  $$NoteNodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false}) {
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
                    if (parentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.parentId,
                        referencedTable: $$NoteNodesTableReferences
                            ._parentIdTable(db),
                        referencedColumn: $$NoteNodesTableReferences
                            ._parentIdTable(db)
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

typedef $$NoteNodesTableProcessedTableManager =
    ProcessedTableManager<
      _$QuestlogDatabase,
      $NoteNodesTable,
      NoteNodeRow,
      $$NoteNodesTableFilterComposer,
      $$NoteNodesTableOrderingComposer,
      $$NoteNodesTableAnnotationComposer,
      $$NoteNodesTableCreateCompanionBuilder,
      $$NoteNodesTableUpdateCompanionBuilder,
      (NoteNodeRow, $$NoteNodesTableReferences),
      NoteNodeRow,
      PrefetchHooks Function({bool parentId})
    >;

class $QuestlogDatabaseManager {
  final _$QuestlogDatabase _db;
  $QuestlogDatabaseManager(this._db);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$MissionsTableTableManager get missions =>
      $$MissionsTableTableManager(_db, _db.missions);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$RuleQuestsTableTableManager get ruleQuests =>
      $$RuleQuestsTableTableManager(_db, _db.ruleQuests);
  $$AppStateTableTableManager get appState =>
      $$AppStateTableTableManager(_db, _db.appState);
  $$CalendarSkippedDatesTableTableManager get calendarSkippedDates =>
      $$CalendarSkippedDatesTableTableManager(_db, _db.calendarSkippedDates);
  $$CalendarCompletionsTableTableManager get calendarCompletions =>
      $$CalendarCompletionsTableTableManager(_db, _db.calendarCompletions);
  $$CalendarAddressesTableTableManager get calendarAddresses =>
      $$CalendarAddressesTableTableManager(_db, _db.calendarAddresses);
  $$NoteNodesTableTableManager get noteNodes =>
      $$NoteNodesTableTableManager(_db, _db.noteNodes);
}
