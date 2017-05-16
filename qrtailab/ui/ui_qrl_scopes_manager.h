/********************************************************************************
** Form generated from reading UI file 'qrl_scopes_manager.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QRL_SCOPES_MANAGER_H
#define UI_QRL_SCOPES_MANAGER_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QComboBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QGroupBox>
#include <QtGui/QHBoxLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QListWidget>
#include <QtGui/QProgressBar>
#include <QtGui/QPushButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QTabWidget>
#include <QtGui/QToolBox>
#include <QtGui/QVBoxLayout>
#include <QtGui/QWidget>
#include "qwt_counter.h"
#include "qwt_wheel.h"

QT_BEGIN_NAMESPACE

class Ui_QRL_ScopesManager
{
public:
    QGridLayout *gridLayout_2;
    QHBoxLayout *hboxLayout;
    QSpacerItem *spacerItem;
    QPushButton *helpButton;
    QSpacerItem *spacerItem1;
    QPushButton *closeButton;
    QSpacerItem *spacerItem2;
    QListWidget *scopeListWidget;
    QTabWidget *tabWidget;
    QWidget *Scope;
    QGridLayout *gridLayout_5;
    QCheckBox *showCheckBox;
    QCheckBox *holdCheckBox;
    QToolBox *toolBox;
    QWidget *Seite;
    QGridLayout *gridLayout_4;
    QLabel *maxLabel_4;
    QwtCounter *dividerCounter;
    QLabel *dataPointLabel;
    QwtCounter *dataCounter;
    QLabel *maxLabel_3;
    QwtCounter *rrCounter;
    QLabel *maxLabel_2;
    QComboBox *dxComboBox;
    QComboBox *displayComboBox;
    QComboBox *directionComboBox;
    QComboBox *optionComboBox;
    QWidget *page;
    QGridLayout *gridLayout;
    QCheckBox *oneShotCheckBox;
    QPushButton *startTriggerPushButton;
    QLabel *label_3;
    QSpacerItem *spacerItem3;
    QwtCounter *triggerCounter;
    QComboBox *traceComboBox;
    QPushButton *triggerPushButton;
    QSpacerItem *spacerItem4;
    QWidget *page_2;
    QGridLayout *gridLayout1;
    QLabel *label_2;
    QLineEdit *dirLineEdit;
    QwtCounter *timeCounter;
    QProgressBar *saveProgressBar;
    QPushButton *savePushButton;
    QPushButton *stopPushButton;
    QPushButton *dirPushButton;
    QLabel *label_5;
    QLineEdit *fileLineEdit;
    QLabel *label;
    QWidget *Trace;
    QGridLayout *gridLayout_3;
    QHBoxLayout *hboxLayout1;
    QLabel *label_4;
    QLineEdit *traceNameLineEdit;
    QToolBox *toolBox_2;
    QWidget *page_3;
    QGridLayout *gridLayout_10;
    QGroupBox *groupBox_4;
    QGridLayout *gridLayout_9;
    QPushButton *fitDyPushButton;
    QHBoxLayout *horizontalLayout_3;
    QLabel *label_6;
    QComboBox *dyComboBox;
    QGroupBox *groupBox_3;
    QGridLayout *gridLayout_8;
    QPushButton *setMeanPushButton;
    QVBoxLayout *verticalLayout;
    QHBoxLayout *horizontalLayout_2;
    QwtCounter *offsetCounter;
    QLabel *offsetLabel;
    QwtWheel *offsetWheel;
    QWidget *page_4;
    QGridLayout *gridLayout_6;
    QCheckBox *showTraceCheckBox;
    QComboBox *styleComboBox;
    QGroupBox *groupBox_2;
    QPushButton *traceColorPushButton;
    QWidget *layoutWidget;
    QHBoxLayout *horizontalLayout;
    QLabel *label_7;
    QwtCounter *lineWidthCounter;
    QComboBox *lineStyleComboBox;
    QGroupBox *groupBox_5;
    QComboBox *symbolStyleComboBox;
    QWidget *layoutWidget1;
    QHBoxLayout *horizontalLayout_4;
    QLabel *label_8;
    QwtCounter *symbolSizeCounter;
    QPushButton *sPenColorPushButton;
    QPushButton *sBrushColorPushButton;
    QWidget *page_5;
    QGridLayout *gridLayout_7;
    QGroupBox *groupBox;
    QGridLayout *gridLayout2;
    QCheckBox *zeroAxisCheckBox;
    QCheckBox *minCheckBox;
    QCheckBox *averageCheckBox;
    QCheckBox *labelCheckBox;
    QCheckBox *maxCheckBox;
    QCheckBox *unitCheckBox;
    QCheckBox *ppCheckBox;
    QCheckBox *rmsCheckBox;

    void setupUi(QDialog *QRL_ScopesManager)
    {
        if (QRL_ScopesManager->objectName().isEmpty())
            QRL_ScopesManager->setObjectName(QString::fromUtf8("QRL_ScopesManager"));
        QRL_ScopesManager->resize(459, 470);
        QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(QRL_ScopesManager->sizePolicy().hasHeightForWidth());
        QRL_ScopesManager->setSizePolicy(sizePolicy);
        QRL_ScopesManager->setMinimumSize(QSize(459, 470));
        QRL_ScopesManager->setMaximumSize(QSize(459, 470));
        QIcon icon;
        icon.addFile(QString::fromUtf8(":/icons/scope_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        QRL_ScopesManager->setWindowIcon(icon);
        gridLayout_2 = new QGridLayout(QRL_ScopesManager);
        gridLayout_2->setObjectName(QString::fromUtf8("gridLayout_2"));
        hboxLayout = new QHBoxLayout();
        hboxLayout->setObjectName(QString::fromUtf8("hboxLayout"));
        spacerItem = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem);

        helpButton = new QPushButton(QRL_ScopesManager);
        helpButton->setObjectName(QString::fromUtf8("helpButton"));

        hboxLayout->addWidget(helpButton);

        spacerItem1 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem1);

        closeButton = new QPushButton(QRL_ScopesManager);
        closeButton->setObjectName(QString::fromUtf8("closeButton"));

        hboxLayout->addWidget(closeButton);

        spacerItem2 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem2);


        gridLayout_2->addLayout(hboxLayout, 1, 0, 1, 3);

        scopeListWidget = new QListWidget(QRL_ScopesManager);
        scopeListWidget->setObjectName(QString::fromUtf8("scopeListWidget"));
        sizePolicy.setHeightForWidth(scopeListWidget->sizePolicy().hasHeightForWidth());
        scopeListWidget->setSizePolicy(sizePolicy);
        scopeListWidget->setMaximumSize(QSize(200, 16777215));
        scopeListWidget->setBaseSize(QSize(100, 0));

        gridLayout_2->addWidget(scopeListWidget, 0, 0, 1, 1);

        tabWidget = new QTabWidget(QRL_ScopesManager);
        tabWidget->setObjectName(QString::fromUtf8("tabWidget"));
        Scope = new QWidget();
        Scope->setObjectName(QString::fromUtf8("Scope"));
        gridLayout_5 = new QGridLayout(Scope);
        gridLayout_5->setObjectName(QString::fromUtf8("gridLayout_5"));
        showCheckBox = new QCheckBox(Scope);
        showCheckBox->setObjectName(QString::fromUtf8("showCheckBox"));

        gridLayout_5->addWidget(showCheckBox, 0, 0, 1, 1);

        holdCheckBox = new QCheckBox(Scope);
        holdCheckBox->setObjectName(QString::fromUtf8("holdCheckBox"));

        gridLayout_5->addWidget(holdCheckBox, 0, 1, 1, 1);

        toolBox = new QToolBox(Scope);
        toolBox->setObjectName(QString::fromUtf8("toolBox"));
        Seite = new QWidget();
        Seite->setObjectName(QString::fromUtf8("Seite"));
        Seite->setGeometry(QRect(0, 0, 211, 259));
        gridLayout_4 = new QGridLayout(Seite);
        gridLayout_4->setObjectName(QString::fromUtf8("gridLayout_4"));
        maxLabel_4 = new QLabel(Seite);
        maxLabel_4->setObjectName(QString::fromUtf8("maxLabel_4"));

        gridLayout_4->addWidget(maxLabel_4, 0, 0, 1, 2);

        dividerCounter = new QwtCounter(Seite);
        dividerCounter->setObjectName(QString::fromUtf8("dividerCounter"));
        dividerCounter->setEnabled(true);
        dividerCounter->setNumButtons(1);
        dividerCounter->setProperty("basicstep", QVariant(1));
        dividerCounter->setMinValue(1);
        dividerCounter->setMaxValue(100000);
        dividerCounter->setStepButton1(1);
        dividerCounter->setStepButton2(10);
        dividerCounter->setStepButton3(100);
        dividerCounter->setValue(1);
        dividerCounter->setEditable(true);

        gridLayout_4->addWidget(dividerCounter, 0, 2, 1, 1);

        dataPointLabel = new QLabel(Seite);
        dataPointLabel->setObjectName(QString::fromUtf8("dataPointLabel"));

        gridLayout_4->addWidget(dataPointLabel, 1, 0, 1, 1);

        dataCounter = new QwtCounter(Seite);
        dataCounter->setObjectName(QString::fromUtf8("dataCounter"));
        dataCounter->setEnabled(true);
        dataCounter->setNumButtons(0);
        dataCounter->setProperty("basicstep", QVariant(1));
        dataCounter->setMinValue(5);
        dataCounter->setMaxValue(100000);
        dataCounter->setStepButton1(100);
        dataCounter->setStepButton2(1000);
        dataCounter->setStepButton3(5000);
        dataCounter->setValue(100);
        dataCounter->setEditable(false);

        gridLayout_4->addWidget(dataCounter, 1, 1, 1, 2);

        maxLabel_3 = new QLabel(Seite);
        maxLabel_3->setObjectName(QString::fromUtf8("maxLabel_3"));

        gridLayout_4->addWidget(maxLabel_3, 2, 0, 1, 1);

        rrCounter = new QwtCounter(Seite);
        rrCounter->setObjectName(QString::fromUtf8("rrCounter"));
        rrCounter->setNumButtons(1);
        rrCounter->setProperty("basicstep", QVariant(1));
        rrCounter->setMinValue(0.001);
        rrCounter->setMaxValue(1e+06);
        rrCounter->setStepButton1(1);
        rrCounter->setValue(20);

        gridLayout_4->addWidget(rrCounter, 2, 1, 1, 2);

        maxLabel_2 = new QLabel(Seite);
        maxLabel_2->setObjectName(QString::fromUtf8("maxLabel_2"));

        gridLayout_4->addWidget(maxLabel_2, 3, 0, 1, 1);

        dxComboBox = new QComboBox(Seite);
        dxComboBox->setObjectName(QString::fromUtf8("dxComboBox"));
        dxComboBox->setEditable(true);
        dxComboBox->setMinimumContentsLength(1);

        gridLayout_4->addWidget(dxComboBox, 3, 1, 1, 2);

        displayComboBox = new QComboBox(Seite);
        displayComboBox->setObjectName(QString::fromUtf8("displayComboBox"));

        gridLayout_4->addWidget(displayComboBox, 4, 0, 1, 3);

        directionComboBox = new QComboBox(Seite);
        directionComboBox->setObjectName(QString::fromUtf8("directionComboBox"));

        gridLayout_4->addWidget(directionComboBox, 5, 0, 1, 3);

        optionComboBox = new QComboBox(Seite);
        optionComboBox->setObjectName(QString::fromUtf8("optionComboBox"));

        gridLayout_4->addWidget(optionComboBox, 6, 0, 1, 3);

        toolBox->addItem(Seite, QString::fromUtf8("Display"));
        page = new QWidget();
        page->setObjectName(QString::fromUtf8("page"));
        page->setGeometry(QRect(0, 0, 197, 147));
        gridLayout = new QGridLayout(page);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        oneShotCheckBox = new QCheckBox(page);
        oneShotCheckBox->setObjectName(QString::fromUtf8("oneShotCheckBox"));

        gridLayout->addWidget(oneShotCheckBox, 0, 0, 1, 1);

        startTriggerPushButton = new QPushButton(page);
        startTriggerPushButton->setObjectName(QString::fromUtf8("startTriggerPushButton"));

        gridLayout->addWidget(startTriggerPushButton, 0, 1, 1, 1);

        label_3 = new QLabel(page);
        label_3->setObjectName(QString::fromUtf8("label_3"));

        gridLayout->addWidget(label_3, 1, 0, 1, 1);

        spacerItem3 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout->addItem(spacerItem3, 1, 1, 1, 1);

        triggerCounter = new QwtCounter(page);
        triggerCounter->setObjectName(QString::fromUtf8("triggerCounter"));
        triggerCounter->setNumButtons(0);
        triggerCounter->setProperty("basicstep", QVariant(0.1));
        triggerCounter->setMinValue(-1e+06);
        triggerCounter->setMaxValue(1e+06);

        gridLayout->addWidget(triggerCounter, 2, 0, 1, 1);

        traceComboBox = new QComboBox(page);
        traceComboBox->setObjectName(QString::fromUtf8("traceComboBox"));

        gridLayout->addWidget(traceComboBox, 2, 1, 1, 1);

        triggerPushButton = new QPushButton(page);
        triggerPushButton->setObjectName(QString::fromUtf8("triggerPushButton"));

        gridLayout->addWidget(triggerPushButton, 3, 0, 1, 2);

        spacerItem4 = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);

        gridLayout->addItem(spacerItem4, 4, 0, 1, 1);

        toolBox->addItem(page, QString::fromUtf8("Trigger"));
        page_2 = new QWidget();
        page_2->setObjectName(QString::fromUtf8("page_2"));
        page_2->setGeometry(QRect(0, 0, 213, 231));
        gridLayout1 = new QGridLayout(page_2);
        gridLayout1->setObjectName(QString::fromUtf8("gridLayout1"));
        label_2 = new QLabel(page_2);
        label_2->setObjectName(QString::fromUtf8("label_2"));

        gridLayout1->addWidget(label_2, 0, 0, 1, 1);

        dirLineEdit = new QLineEdit(page_2);
        dirLineEdit->setObjectName(QString::fromUtf8("dirLineEdit"));

        gridLayout1->addWidget(dirLineEdit, 1, 0, 1, 2);

        timeCounter = new QwtCounter(page_2);
        timeCounter->setObjectName(QString::fromUtf8("timeCounter"));
        timeCounter->setLayoutDirection(Qt::RightToLeft);
        timeCounter->setNumButtons(0);
        timeCounter->setMinValue(0);
        timeCounter->setMaxValue(1e+06);
        timeCounter->setValue(1);

        gridLayout1->addWidget(timeCounter, 7, 0, 1, 2);

        saveProgressBar = new QProgressBar(page_2);
        saveProgressBar->setObjectName(QString::fromUtf8("saveProgressBar"));
        saveProgressBar->setEnabled(false);
        saveProgressBar->setValue(100);

        gridLayout1->addWidget(saveProgressBar, 8, 0, 1, 2);

        savePushButton = new QPushButton(page_2);
        savePushButton->setObjectName(QString::fromUtf8("savePushButton"));
        savePushButton->setCheckable(true);
        savePushButton->setAutoDefault(false);

        gridLayout1->addWidget(savePushButton, 11, 0, 1, 1);

        stopPushButton = new QPushButton(page_2);
        stopPushButton->setObjectName(QString::fromUtf8("stopPushButton"));
        stopPushButton->setEnabled(false);

        gridLayout1->addWidget(stopPushButton, 11, 1, 1, 1);

        dirPushButton = new QPushButton(page_2);
        dirPushButton->setObjectName(QString::fromUtf8("dirPushButton"));

        gridLayout1->addWidget(dirPushButton, 0, 1, 1, 1);

        label_5 = new QLabel(page_2);
        label_5->setObjectName(QString::fromUtf8("label_5"));

        gridLayout1->addWidget(label_5, 2, 0, 1, 1);

        fileLineEdit = new QLineEdit(page_2);
        fileLineEdit->setObjectName(QString::fromUtf8("fileLineEdit"));

        gridLayout1->addWidget(fileLineEdit, 2, 1, 1, 1);

        label = new QLabel(page_2);
        label->setObjectName(QString::fromUtf8("label"));

        gridLayout1->addWidget(label, 6, 0, 1, 1);

        toolBox->addItem(page_2, QString::fromUtf8("Saving"));

        gridLayout_5->addWidget(toolBox, 1, 0, 1, 2);

        tabWidget->addTab(Scope, QString());
        Trace = new QWidget();
        Trace->setObjectName(QString::fromUtf8("Trace"));
        gridLayout_3 = new QGridLayout(Trace);
        gridLayout_3->setObjectName(QString::fromUtf8("gridLayout_3"));
        hboxLayout1 = new QHBoxLayout();
        hboxLayout1->setObjectName(QString::fromUtf8("hboxLayout1"));
        label_4 = new QLabel(Trace);
        label_4->setObjectName(QString::fromUtf8("label_4"));

        hboxLayout1->addWidget(label_4);

        traceNameLineEdit = new QLineEdit(Trace);
        traceNameLineEdit->setObjectName(QString::fromUtf8("traceNameLineEdit"));

        hboxLayout1->addWidget(traceNameLineEdit);


        gridLayout_3->addLayout(hboxLayout1, 0, 0, 1, 2);

        toolBox_2 = new QToolBox(Trace);
        toolBox_2->setObjectName(QString::fromUtf8("toolBox_2"));
        toolBox_2->setMinimumSize(QSize(227, 0));
        page_3 = new QWidget();
        page_3->setObjectName(QString::fromUtf8("page_3"));
        page_3->setGeometry(QRect(0, 0, 218, 256));
        gridLayout_10 = new QGridLayout(page_3);
        gridLayout_10->setObjectName(QString::fromUtf8("gridLayout_10"));
        groupBox_4 = new QGroupBox(page_3);
        groupBox_4->setObjectName(QString::fromUtf8("groupBox_4"));
        groupBox_4->setMaximumSize(QSize(200, 110));
        gridLayout_9 = new QGridLayout(groupBox_4);
        gridLayout_9->setObjectName(QString::fromUtf8("gridLayout_9"));
        fitDyPushButton = new QPushButton(groupBox_4);
        fitDyPushButton->setObjectName(QString::fromUtf8("fitDyPushButton"));

        gridLayout_9->addWidget(fitDyPushButton, 0, 0, 1, 1);

        horizontalLayout_3 = new QHBoxLayout();
        horizontalLayout_3->setObjectName(QString::fromUtf8("horizontalLayout_3"));
        label_6 = new QLabel(groupBox_4);
        label_6->setObjectName(QString::fromUtf8("label_6"));
        sizePolicy.setHeightForWidth(label_6->sizePolicy().hasHeightForWidth());
        label_6->setSizePolicy(sizePolicy);

        horizontalLayout_3->addWidget(label_6);

        dyComboBox = new QComboBox(groupBox_4);
        dyComboBox->setObjectName(QString::fromUtf8("dyComboBox"));
        dyComboBox->setMinimumSize(QSize(120, 0));
        dyComboBox->setEditable(true);
        dyComboBox->setMaxVisibleItems(20);

        horizontalLayout_3->addWidget(dyComboBox);


        gridLayout_9->addLayout(horizontalLayout_3, 1, 0, 1, 1);


        gridLayout_10->addWidget(groupBox_4, 1, 0, 1, 1);

        groupBox_3 = new QGroupBox(page_3);
        groupBox_3->setObjectName(QString::fromUtf8("groupBox_3"));
        groupBox_3->setMaximumSize(QSize(200, 130));
        gridLayout_8 = new QGridLayout(groupBox_3);
        gridLayout_8->setObjectName(QString::fromUtf8("gridLayout_8"));
        setMeanPushButton = new QPushButton(groupBox_3);
        setMeanPushButton->setObjectName(QString::fromUtf8("setMeanPushButton"));
        QSizePolicy sizePolicy1(QSizePolicy::Minimum, QSizePolicy::Minimum);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(setMeanPushButton->sizePolicy().hasHeightForWidth());
        setMeanPushButton->setSizePolicy(sizePolicy1);

        gridLayout_8->addWidget(setMeanPushButton, 0, 0, 1, 1);

        verticalLayout = new QVBoxLayout();
        verticalLayout->setObjectName(QString::fromUtf8("verticalLayout"));
        horizontalLayout_2 = new QHBoxLayout();
        horizontalLayout_2->setObjectName(QString::fromUtf8("horizontalLayout_2"));
        offsetCounter = new QwtCounter(groupBox_3);
        offsetCounter->setObjectName(QString::fromUtf8("offsetCounter"));
        QSizePolicy sizePolicy2(QSizePolicy::Preferred, QSizePolicy::Minimum);
        sizePolicy2.setHorizontalStretch(0);
        sizePolicy2.setVerticalStretch(0);
        sizePolicy2.setHeightForWidth(offsetCounter->sizePolicy().hasHeightForWidth());
        offsetCounter->setSizePolicy(sizePolicy2);
        offsetCounter->setNumButtons(0);
        offsetCounter->setProperty("basicstep", QVariant(0.1));
        offsetCounter->setMinValue(-1e+06);
        offsetCounter->setMaxValue(1e+06);

        horizontalLayout_2->addWidget(offsetCounter);

        offsetLabel = new QLabel(groupBox_3);
        offsetLabel->setObjectName(QString::fromUtf8("offsetLabel"));

        horizontalLayout_2->addWidget(offsetLabel);


        verticalLayout->addLayout(horizontalLayout_2);

        offsetWheel = new QwtWheel(groupBox_3);
        offsetWheel->setObjectName(QString::fromUtf8("offsetWheel"));
        sizePolicy2.setHeightForWidth(offsetWheel->sizePolicy().hasHeightForWidth());
        offsetWheel->setSizePolicy(sizePolicy2);
        offsetWheel->setMass(1);

        verticalLayout->addWidget(offsetWheel);


        gridLayout_8->addLayout(verticalLayout, 1, 0, 1, 1);


        gridLayout_10->addWidget(groupBox_3, 0, 0, 1, 1);

        toolBox_2->addItem(page_3, QString::fromUtf8("offset / dy"));
        page_4 = new QWidget();
        page_4->setObjectName(QString::fromUtf8("page_4"));
        page_4->setGeometry(QRect(0, 0, 148, 145));
        gridLayout_6 = new QGridLayout(page_4);
        gridLayout_6->setObjectName(QString::fromUtf8("gridLayout_6"));
        showTraceCheckBox = new QCheckBox(page_4);
        showTraceCheckBox->setObjectName(QString::fromUtf8("showTraceCheckBox"));

        gridLayout_6->addWidget(showTraceCheckBox, 0, 0, 1, 1);

        styleComboBox = new QComboBox(page_4);
        styleComboBox->setObjectName(QString::fromUtf8("styleComboBox"));
        styleComboBox->setFocusPolicy(Qt::ClickFocus);

        gridLayout_6->addWidget(styleComboBox, 1, 0, 1, 1);

        groupBox_2 = new QGroupBox(page_4);
        groupBox_2->setObjectName(QString::fromUtf8("groupBox_2"));
        traceColorPushButton = new QPushButton(groupBox_2);
        traceColorPushButton->setObjectName(QString::fromUtf8("traceColorPushButton"));
        traceColorPushButton->setGeometry(QRect(130, 60, 51, 21));
        layoutWidget = new QWidget(groupBox_2);
        layoutWidget->setObjectName(QString::fromUtf8("layoutWidget"));
        layoutWidget->setGeometry(QRect(10, 40, 81, 39));
        horizontalLayout = new QHBoxLayout(layoutWidget);
        horizontalLayout->setObjectName(QString::fromUtf8("horizontalLayout"));
        horizontalLayout->setContentsMargins(0, 0, 0, 0);
        label_7 = new QLabel(layoutWidget);
        label_7->setObjectName(QString::fromUtf8("label_7"));

        horizontalLayout->addWidget(label_7);

        lineWidthCounter = new QwtCounter(layoutWidget);
        lineWidthCounter->setObjectName(QString::fromUtf8("lineWidthCounter"));
        lineWidthCounter->setNumButtons(0);
        lineWidthCounter->setProperty("basicstep", QVariant(1));
        lineWidthCounter->setMinValue(1);
        lineWidthCounter->setMaxValue(50);

        horizontalLayout->addWidget(lineWidthCounter);

        lineStyleComboBox = new QComboBox(groupBox_2);
        lineStyleComboBox->setObjectName(QString::fromUtf8("lineStyleComboBox"));
        lineStyleComboBox->setGeometry(QRect(120, 30, 77, 26));

        gridLayout_6->addWidget(groupBox_2, 2, 0, 1, 1);

        groupBox_5 = new QGroupBox(page_4);
        groupBox_5->setObjectName(QString::fromUtf8("groupBox_5"));
        symbolStyleComboBox = new QComboBox(groupBox_5);
        symbolStyleComboBox->setObjectName(QString::fromUtf8("symbolStyleComboBox"));
        symbolStyleComboBox->setGeometry(QRect(10, 60, 91, 26));
        layoutWidget1 = new QWidget(groupBox_5);
        layoutWidget1->setObjectName(QString::fromUtf8("layoutWidget1"));
        layoutWidget1->setGeometry(QRect(10, 30, 114, 30));
        horizontalLayout_4 = new QHBoxLayout(layoutWidget1);
        horizontalLayout_4->setObjectName(QString::fromUtf8("horizontalLayout_4"));
        horizontalLayout_4->setContentsMargins(0, 0, 0, 0);
        label_8 = new QLabel(layoutWidget1);
        label_8->setObjectName(QString::fromUtf8("label_8"));

        horizontalLayout_4->addWidget(label_8);

        symbolSizeCounter = new QwtCounter(layoutWidget1);
        symbolSizeCounter->setObjectName(QString::fromUtf8("symbolSizeCounter"));
        symbolSizeCounter->setNumButtons(0);
        symbolSizeCounter->setProperty("basicstep", QVariant(1));
        symbolSizeCounter->setMinValue(1);
        symbolSizeCounter->setMaxValue(50);

        horizontalLayout_4->addWidget(symbolSizeCounter);

        sPenColorPushButton = new QPushButton(groupBox_5);
        sPenColorPushButton->setObjectName(QString::fromUtf8("sPenColorPushButton"));
        sPenColorPushButton->setGeometry(QRect(140, 30, 41, 21));
        sBrushColorPushButton = new QPushButton(groupBox_5);
        sBrushColorPushButton->setObjectName(QString::fromUtf8("sBrushColorPushButton"));
        sBrushColorPushButton->setGeometry(QRect(140, 60, 51, 21));

        gridLayout_6->addWidget(groupBox_5, 3, 0, 1, 1);

        toolBox_2->addItem(page_4, QString::fromUtf8("Trace Options"));
        page_5 = new QWidget();
        page_5->setObjectName(QString::fromUtf8("page_5"));
        page_5->setGeometry(QRect(0, 0, 223, 160));
        gridLayout_7 = new QGridLayout(page_5);
        gridLayout_7->setObjectName(QString::fromUtf8("gridLayout_7"));
        groupBox = new QGroupBox(page_5);
        groupBox->setObjectName(QString::fromUtf8("groupBox"));
        gridLayout2 = new QGridLayout(groupBox);
        gridLayout2->setObjectName(QString::fromUtf8("gridLayout2"));
        zeroAxisCheckBox = new QCheckBox(groupBox);
        zeroAxisCheckBox->setObjectName(QString::fromUtf8("zeroAxisCheckBox"));

        gridLayout2->addWidget(zeroAxisCheckBox, 0, 0, 1, 1);

        minCheckBox = new QCheckBox(groupBox);
        minCheckBox->setObjectName(QString::fromUtf8("minCheckBox"));
        minCheckBox->setEnabled(true);

        gridLayout2->addWidget(minCheckBox, 0, 1, 1, 1);

        averageCheckBox = new QCheckBox(groupBox);
        averageCheckBox->setObjectName(QString::fromUtf8("averageCheckBox"));
        averageCheckBox->setEnabled(true);

        gridLayout2->addWidget(averageCheckBox, 3, 1, 1, 1);

        labelCheckBox = new QCheckBox(groupBox);
        labelCheckBox->setObjectName(QString::fromUtf8("labelCheckBox"));
        labelCheckBox->setEnabled(true);

        gridLayout2->addWidget(labelCheckBox, 1, 0, 1, 1);

        maxCheckBox = new QCheckBox(groupBox);
        maxCheckBox->setObjectName(QString::fromUtf8("maxCheckBox"));
        maxCheckBox->setEnabled(true);

        gridLayout2->addWidget(maxCheckBox, 1, 1, 1, 1);

        unitCheckBox = new QCheckBox(groupBox);
        unitCheckBox->setObjectName(QString::fromUtf8("unitCheckBox"));
        unitCheckBox->setEnabled(true);

        gridLayout2->addWidget(unitCheckBox, 3, 0, 1, 1);

        ppCheckBox = new QCheckBox(groupBox);
        ppCheckBox->setObjectName(QString::fromUtf8("ppCheckBox"));
        ppCheckBox->setEnabled(true);

        gridLayout2->addWidget(ppCheckBox, 4, 0, 1, 1);

        rmsCheckBox = new QCheckBox(groupBox);
        rmsCheckBox->setObjectName(QString::fromUtf8("rmsCheckBox"));
        rmsCheckBox->setEnabled(true);

        gridLayout2->addWidget(rmsCheckBox, 4, 1, 1, 1);


        gridLayout_7->addWidget(groupBox, 0, 0, 1, 1);

        toolBox_2->addItem(page_5, QString::fromUtf8("Labels"));

        gridLayout_3->addWidget(toolBox_2, 1, 0, 1, 2);

        tabWidget->addTab(Trace, QString());

        gridLayout_2->addWidget(tabWidget, 0, 1, 1, 1);


        retranslateUi(QRL_ScopesManager);
        QObject::connect(closeButton, SIGNAL(clicked()), QRL_ScopesManager, SLOT(hide()));

        tabWidget->setCurrentIndex(0);
        toolBox->setCurrentIndex(0);
        dxComboBox->setCurrentIndex(8);
        toolBox_2->setCurrentIndex(0);
        dyComboBox->setCurrentIndex(10);
        lineStyleComboBox->setCurrentIndex(1);


        QMetaObject::connectSlotsByName(QRL_ScopesManager);
    } // setupUi

    void retranslateUi(QDialog *QRL_ScopesManager)
    {
        QRL_ScopesManager->setWindowTitle(QApplication::translate("QRL_ScopesManager", "Scopes Manager", 0, QApplication::UnicodeUTF8));
        helpButton->setText(QApplication::translate("QRL_ScopesManager", "Help", 0, QApplication::UnicodeUTF8));
        closeButton->setText(QApplication::translate("QRL_ScopesManager", "Close Manager", 0, QApplication::UnicodeUTF8));
        showCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Show/Hide", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        holdCheckBox->setToolTip(QApplication::translate("QRL_ScopesManager", "stop plotting will reduce cpu load. Saving is still possible!", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        holdCheckBox->setText(QApplication::translate("QRL_ScopesManager", "hold Plot", 0, QApplication::UnicodeUTF8));
        maxLabel_4->setText(QApplication::translate("QRL_ScopesManager", "DataDivider", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        dividerCounter->setToolTip(QApplication::translate("QRL_ScopesManager", "Reduces the Number of plotted points. Can be used to reduce cpu load.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        dataPointLabel->setText(QApplication::translate("QRL_ScopesManager", "Data points", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        dataCounter->setToolTip(QApplication::translate("QRL_ScopesManager", "Number of shown data points in the plot window.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        maxLabel_3->setText(QApplication::translate("QRL_ScopesManager", "Frames/s", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        rrCounter->setToolTip(QApplication::translate("QRL_ScopesManager", "frames per seconds", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        maxLabel_2->setText(QApplication::translate("QRL_ScopesManager", "sec/div", 0, QApplication::UnicodeUTF8));
        dxComboBox->clear();
        dxComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "0.0001", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.0005", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.001", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.005", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.01", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.05", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "10", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "50", 0, QApplication::UnicodeUTF8)
        );
#ifndef QT_NO_TOOLTIP
        dxComboBox->setToolTip(QApplication::translate("QRL_ScopesManager", "set the seconds per devision to scale the x-axis of the plot.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        displayComboBox->clear();
        displayComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "Continuous Roling", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Overwrite", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Trigger +to-", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Trigger -to+", 0, QApplication::UnicodeUTF8)
        );
#ifndef QT_NO_TOOLTIP
        displayComboBox->setToolTip(QApplication::translate("QRL_ScopesManager", "Plotting mode", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        directionComboBox->clear();
        directionComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "right to left", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "left to right", 0, QApplication::UnicodeUTF8)
        );
#ifndef QT_NO_TOOLTIP
        directionComboBox->setToolTip(QApplication::translate("QRL_ScopesManager", "Plotting direction", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        optionComboBox->clear();
        optionComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "Show Grid", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "set BG Color", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "set Grid Color", 0, QApplication::UnicodeUTF8)
        );
        toolBox->setItemText(toolBox->indexOf(Seite), QApplication::translate("QRL_ScopesManager", "Display", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        oneShotCheckBox->setToolTip(QApplication::translate("QRL_ScopesManager", "Enable one shot triggering. Press the start button to restart triggering. ", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        oneShotCheckBox->setText(QApplication::translate("QRL_ScopesManager", "One Shot", 0, QApplication::UnicodeUTF8));
        startTriggerPushButton->setText(QApplication::translate("QRL_ScopesManager", "Start", 0, QApplication::UnicodeUTF8));
        label_3->setText(QApplication::translate("QRL_ScopesManager", "Trigger offset", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        triggerCounter->setToolTip(QApplication::translate("QRL_ScopesManager", "trigger barrier", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        traceComboBox->clear();
        traceComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "Trace 1", 0, QApplication::UnicodeUTF8)
        );
#ifndef QT_NO_TOOLTIP
        traceComboBox->setToolTip(QApplication::translate("QRL_ScopesManager", "trigger source", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
#ifndef QT_NO_TOOLTIP
        triggerPushButton->setToolTip(QApplication::translate("QRL_ScopesManager", "Releases a trigger event.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        triggerPushButton->setText(QApplication::translate("QRL_ScopesManager", "Manual Trigger", 0, QApplication::UnicodeUTF8));
        toolBox->setItemText(toolBox->indexOf(page), QApplication::translate("QRL_ScopesManager", "Trigger", 0, QApplication::UnicodeUTF8));
        label_2->setText(QApplication::translate("QRL_ScopesManager", "Directory", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        dirLineEdit->setToolTip(QApplication::translate("QRL_ScopesManager", "File directory", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        dirLineEdit->setText(QApplication::translate("QRL_ScopesManager", "./", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        timeCounter->setToolTip(QApplication::translate("QRL_ScopesManager", "Time duration of the next saving", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
#ifndef QT_NO_TOOLTIP
        savePushButton->setToolTip(QApplication::translate("QRL_ScopesManager", "start saving", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        savePushButton->setText(QApplication::translate("QRL_ScopesManager", "Save", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        stopPushButton->setToolTip(QApplication::translate("QRL_ScopesManager", "stop saving", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        stopPushButton->setText(QApplication::translate("QRL_ScopesManager", "stop", 0, QApplication::UnicodeUTF8));
        dirPushButton->setText(QApplication::translate("QRL_ScopesManager", "Set Directory", 0, QApplication::UnicodeUTF8));
        label_5->setText(QApplication::translate("QRL_ScopesManager", "FileName", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        fileLineEdit->setToolTip(QApplication::translate("QRL_ScopesManager", "file name", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        label->setText(QApplication::translate("QRL_ScopesManager", "Time [s]", 0, QApplication::UnicodeUTF8));
        toolBox->setItemText(toolBox->indexOf(page_2), QApplication::translate("QRL_ScopesManager", "Saving", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(Scope), QApplication::translate("QRL_ScopesManager", "Scope", 0, QApplication::UnicodeUTF8));
        label_4->setText(QApplication::translate("QRL_ScopesManager", "name", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        traceNameLineEdit->setToolTip(QApplication::translate("QRL_ScopesManager", "set a  new trace name", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        groupBox_4->setTitle(QApplication::translate("QRL_ScopesManager", "dy", 0, QApplication::UnicodeUTF8));
        fitDyPushButton->setText(QApplication::translate("QRL_ScopesManager", "fit to PP", 0, QApplication::UnicodeUTF8));
        label_6->setText(QApplication::translate("QRL_ScopesManager", "Units/div:", 0, QApplication::UnicodeUTF8));
        dyComboBox->clear();
        dyComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "0.001", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.002", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.005", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.01", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.02", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.05", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.2", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "0.5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "2", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "5", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "10", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "50", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "100", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "1000", 0, QApplication::UnicodeUTF8)
        );
        groupBox_3->setTitle(QApplication::translate("QRL_ScopesManager", "offset", 0, QApplication::UnicodeUTF8));
        setMeanPushButton->setText(QApplication::translate("QRL_ScopesManager", "set to mean", 0, QApplication::UnicodeUTF8));
        offsetLabel->setText(QApplication::translate("QRL_ScopesManager", "div", 0, QApplication::UnicodeUTF8));
        toolBox_2->setItemText(toolBox_2->indexOf(page_3), QApplication::translate("QRL_ScopesManager", "offset / dy", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        showTraceCheckBox->setToolTip(QString());
#endif // QT_NO_TOOLTIP
        showTraceCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Show/Hide", 0, QApplication::UnicodeUTF8));
        styleComboBox->clear();
        styleComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "Templates", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Line / None", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Line / Cross", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Sticks / Ellipse", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Steps / None", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "None / XCross", 0, QApplication::UnicodeUTF8)
        );
        groupBox_2->setTitle(QApplication::translate("QRL_ScopesManager", "Line", 0, QApplication::UnicodeUTF8));
        traceColorPushButton->setText(QApplication::translate("QRL_ScopesManager", "Color", 0, QApplication::UnicodeUTF8));
        label_7->setText(QApplication::translate("QRL_ScopesManager", "width", 0, QApplication::UnicodeUTF8));
        lineStyleComboBox->clear();
        lineStyleComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "NoCurve", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Lines", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Sticks", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Steps", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Dots", 0, QApplication::UnicodeUTF8)
        );
        groupBox_5->setTitle(QApplication::translate("QRL_ScopesManager", "Symbol", 0, QApplication::UnicodeUTF8));
        symbolStyleComboBox->clear();
        symbolStyleComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_ScopesManager", "NoSymbol", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Ellipse", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Rect", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Diamond", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Triangle", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "DTriangle", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "UTriangle", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "LTriangle", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "RTriangle", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Cross", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "XCross", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "HLine", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "VLine", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Star1", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Star2", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_ScopesManager", "Hexagon", 0, QApplication::UnicodeUTF8)
        );
        label_8->setText(QApplication::translate("QRL_ScopesManager", "size", 0, QApplication::UnicodeUTF8));
        sPenColorPushButton->setText(QApplication::translate("QRL_ScopesManager", " Pen", 0, QApplication::UnicodeUTF8));
        sBrushColorPushButton->setText(QApplication::translate("QRL_ScopesManager", "Brush", 0, QApplication::UnicodeUTF8));
        toolBox_2->setItemText(toolBox_2->indexOf(page_4), QApplication::translate("QRL_ScopesManager", "Trace Options", 0, QApplication::UnicodeUTF8));
        groupBox->setTitle(QApplication::translate("QRL_ScopesManager", "show", 0, QApplication::UnicodeUTF8));
        zeroAxisCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Zero Axis", 0, QApplication::UnicodeUTF8));
        minCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Min", 0, QApplication::UnicodeUTF8));
        averageCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Average", 0, QApplication::UnicodeUTF8));
        labelCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Label", 0, QApplication::UnicodeUTF8));
        maxCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Max", 0, QApplication::UnicodeUTF8));
        unitCheckBox->setText(QApplication::translate("QRL_ScopesManager", "Units/div", 0, QApplication::UnicodeUTF8));
        ppCheckBox->setText(QApplication::translate("QRL_ScopesManager", "PP", 0, QApplication::UnicodeUTF8));
        rmsCheckBox->setText(QApplication::translate("QRL_ScopesManager", "RMS", 0, QApplication::UnicodeUTF8));
        toolBox_2->setItemText(toolBox_2->indexOf(page_5), QApplication::translate("QRL_ScopesManager", "Labels", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(Trace), QApplication::translate("QRL_ScopesManager", "Trace options", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class QRL_ScopesManager: public Ui_QRL_ScopesManager {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QRL_SCOPES_MANAGER_H
