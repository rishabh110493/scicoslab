/****************************************************************************
** Meta object code from reading C++ file 'scopes_manager.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/scopes_manager.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'scopes_manager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_ScopesManager[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      50,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      40,   19,   18,   18, 0x0a,
      95,   65,   18,   18, 0x0a,
     124,   18,   18,   18, 0x0a,
     134,   18,   18,   18, 0x0a,
     149,   18,   18,   18, 0x0a,
     164,   18,   18,   18, 0x0a,
     186,   18,   18,   18, 0x0a,
     213,  208,   18,   18, 0x0a,
     243,   18,   18,   18, 0x0a,
     269,   18,   18,   18, 0x0a,
     294,   18,   18,   18, 0x0a,
     316,   18,   18,   18, 0x0a,
     334,   18,   18,   18, 0x0a,
     348,   18,   18,   18, 0x0a,
     361,   18,   18,   18, 0x0a,
     377,   18,   18,   18, 0x0a,
     396,   18,   18,   18, 0x0a,
     421,   18,   18,   18, 0x0a,
     442,   18,   18,   18, 0x0a,
     460,   18,   18,   18, 0x0a,
     484,   18,   18,   18, 0x0a,
     505,   18,   18,   18, 0x0a,
     527,   18,   18,   18, 0x0a,
     548,   18,   18,   18, 0x0a,
     571,   18,   18,   18, 0x0a,
     595,   18,   18,   18, 0x0a,
     618,   18,   18,   18, 0x0a,
     645,   18,   18,   18, 0x0a,
     671,   18,   18,   18, 0x0a,
     687,   18,   18,   18, 0x0a,
     709,   18,   18,   18, 0x0a,
     731,  726,   18,   18, 0x0a,
     756,   18,   18,   18, 0x0a,
     776,   18,   18,   18, 0x0a,
     798,   18,   18,   18, 0x0a,
     819,   18,   18,   18, 0x0a,
     843,   18,   18,   18, 0x0a,
     863,   18,   18,   18, 0x0a,
     883,   18,   18,   18, 0x0a,
     902,   18,   18,   18, 0x0a,
     922,   18,   18,   18, 0x0a,
     936,   18,   18,   18, 0x0a,
     955,   18,   18,   18, 0x0a,
     973,   18,   18,   18, 0x0a,
     985,   18,   18,   18, 0x0a,
    1004,   18,   18,   18, 0x0a,
    1028, 1022,   18,   18, 0x0a,
    1053, 1048,   18,   18, 0x0a,
    1075,   18,   18,   18, 0x0a,
    1100,   18,   18,   18, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_QRL_ScopesManager[] = {
    "QRL_ScopesManager\0\0scopeNumber,filename\0"
    "setFileName(int,QString)\0"
    "scopeNumber,savetime,autosave\0"
    "setSaveTime(int,double,bool)\0refresh()\0"
    "showScope(int)\0showTrace(int)\0"
    "showScopeOptions(int)\0showSelectedOptions()\0"
    "item\0showOptions(QListWidgetItem*)\0"
    "changeRefreshRate(double)\0"
    "changeDataPoints(double)\0changeDivider(double)\0"
    "changeDX(QString)\0startSaving()\0"
    "stopSaving()\0setOptions(int)\0"
    "changeTraceColor()\0changeTraceWidth(double)\0"
    "changeOffset(double)\0changeDy(QString)\0"
    "changeDisplayModus(int)\0changeDirection(int)\0"
    "showTraceOptions(int)\0changeScopeList(int)\0"
    "changeSaveTime(double)\0changeFileName(QString)\0"
    "changeFileDir(QString)\0"
    "changeTriggerLevel(double)\0"
    "changeTriggerChannel(int)\0manualTrigger()\0"
    "changeSingleMode(int)\0startSingleRun()\0"
    "text\0changeTraceText(QString)\0"
    "changeZeroAxis(int)\0changeTraceLabel(int)\0"
    "changeUnitLabel(int)\0changeAverageLabel(int)\0"
    "changeMinLabel(int)\0changeMaxLabel(int)\0"
    "changePPLabel(int)\0changeRMSLabel(int)\0"
    "holdPlot(int)\0setFileDirectory()\0"
    "setOffsetToMean()\0fitDytoPP()\0"
    "setTraceStyle(int)\0setLineStyle(int)\0"
    "index\0setSymbolStyle(int)\0size\0"
    "setSymbolSize(double)\0changeSymbolBrushColor()\0"
    "changeSymbolPenColor()\0"
};

void QRL_ScopesManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_ScopesManager *_t = static_cast<QRL_ScopesManager *>(_o);
        switch (_id) {
        case 0: _t->setFileName((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 1: _t->setSaveTime((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 2: _t->refresh(); break;
        case 3: _t->showScope((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 4: _t->showTrace((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 5: _t->showScopeOptions((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 6: _t->showSelectedOptions(); break;
        case 7: _t->showOptions((*reinterpret_cast< QListWidgetItem*(*)>(_a[1]))); break;
        case 8: _t->changeRefreshRate((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 9: _t->changeDataPoints((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 10: _t->changeDivider((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 11: _t->changeDX((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 12: _t->startSaving(); break;
        case 13: _t->stopSaving(); break;
        case 14: _t->setOptions((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 15: _t->changeTraceColor(); break;
        case 16: _t->changeTraceWidth((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 17: _t->changeOffset((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 18: _t->changeDy((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 19: _t->changeDisplayModus((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 20: _t->changeDirection((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 21: _t->showTraceOptions((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 22: _t->changeScopeList((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 23: _t->changeSaveTime((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 24: _t->changeFileName((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 25: _t->changeFileDir((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 26: _t->changeTriggerLevel((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 27: _t->changeTriggerChannel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 28: _t->manualTrigger(); break;
        case 29: _t->changeSingleMode((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 30: _t->startSingleRun(); break;
        case 31: _t->changeTraceText((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 32: _t->changeZeroAxis((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 33: _t->changeTraceLabel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 34: _t->changeUnitLabel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 35: _t->changeAverageLabel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 36: _t->changeMinLabel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 37: _t->changeMaxLabel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 38: _t->changePPLabel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 39: _t->changeRMSLabel((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 40: _t->holdPlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 41: _t->setFileDirectory(); break;
        case 42: _t->setOffsetToMean(); break;
        case 43: _t->fitDytoPP(); break;
        case 44: _t->setTraceStyle((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 45: _t->setLineStyle((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 46: _t->setSymbolStyle((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 47: _t->setSymbolSize((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 48: _t->changeSymbolBrushColor(); break;
        case 49: _t->changeSymbolPenColor(); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_ScopesManager::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_ScopesManager::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_ScopesManager,
      qt_meta_data_QRL_ScopesManager, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_ScopesManager::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_ScopesManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_ScopesManager::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_ScopesManager))
        return static_cast<void*>(const_cast< QRL_ScopesManager*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_ScopesManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 50)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 50;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
