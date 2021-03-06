//
//  AgentCalls+ServiceProvider.swift
//  Telabook
//
//  Created by Anmol Rajpal on 04/09/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
import CoreData

extension AgentCallsViewController {
    
    
    
    func fetchAgentCalls() {
        let limit = String(self.limit)
        let offset = String(self.offset)
        fetchAgentCalls(limit: limit, offset: offset)
    }
    
    func paginateAgentCalls() {
        guard !isFetching && shouldFetchMore else { return }
        offset = offset + limit
        fetchAgentCalls(limit: String(limit), offset: String(offset))
    }
    
    
    /* ------------------------------------------------------------------------------------------------------------ */
    internal func fetchAgentCalls(limit: String, offset: String) {
        isFetching = true
        handleState()
        let params: [String: String] = [
            "limit": limit,
            "offset": offset
        ]
        
        APIServer<AgentCallsJSON>(apiVersion: .v2).hitEndpoint(endpoint: .FetchAgentCalls(workerID: workerID), httpMethod: .GET, params: params, decoder: JSONDecoder.apiServiceDecoder, completion: agentCallsFetchCompletion)
    }
    /* ------------------------------------------------------------------------------------------------------------ */
    
    
    private func agentCallsFetchCompletion(result: Result<AgentCallsJSON, APIService.APIError>) {
        switch result {
        case .failure(let error):
            self.showAlert(withErrorMessage: error.publicDescription) {
                self.isFetching = false
                self.stopLoaders()
                self.handleState()
            }
        case .success(let resultData):
            let serverResult = resultData.result
            switch serverResult {
            case .failure:
                let errorMessage = "Error: Failed to fetch agent calls from server"
                self.showAlert(withErrorMessage: resultData.message ?? errorMessage) { [self] in
                    isFetching = false
                    stopLoaders()
                    handleState()
                }
            case .success:
                let calls = resultData.agentCalls
                if offset == 0 {
                    persistRecentCalls(calls: calls)
                }
                calls.forEach { call in
                    if let sectionIndex = sections.firstIndex(where: {
                        if let serverDate = call.timestampDate,
                            let sectionDate = $0.groupedCalls.first?.recentCall.timestampDate {
                            return Calendar.current.isDate(sectionDate, inSameDayAs: serverDate)
                        } else {
                            return false
                        }
                    }) {
                        if let groupedCallIndex = sections[sectionIndex].groupedCalls.firstIndex(where: { groupedCall -> Bool in
                                let isCustomerCIDMatched = groupedCall.recentCall.customerCid == call.customerCid
                                let isCallDirectionMatched = groupedCall.recentCall.callDirection == call.callDirection
                                let isCallStatusMatched = groupedCall.recentCall.callStatus == call.callStatus
                                if let recentCallDate = groupedCall.recentCall.timestampDate,
                                    let serverCallDate = call.timestampDate {
                                    let isCallInSameDay = Calendar.current.isDate(recentCallDate, inSameDayAs: serverCallDate)
                                    let allConditionsMatched = isCustomerCIDMatched && isCallDirectionMatched && isCallStatusMatched && isCallInSameDay
                                    return allConditionsMatched
                                }
                                return false
                        }) {
                            sections[sectionIndex].groupedCalls[groupedCallIndex].calls.append(call)
                        } else {
                            sections[sectionIndex].groupedCalls.append(ItemType(calls: [call]))
                        }
                    } else {
                        sections.append(SectionType(groupedCalls: [ItemType(calls: [call])]))
                    }
                }
                isFetching = false
                shouldFetchMore = calls.count == 50
                DispatchQueue.main.async { [self] in
                    updateUI()
                }
                stopLoaders()
            }
        }
    }
    func persistRecentCalls(calls: [AgentCallProperties]) {
        guard let context = worker.managedObjectContext else {
            fatalError("### \(#function) - Failed to retrieve managed object context of agent: \(worker!)")
        }
        context.performAndWait {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(AgentCall.self))
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(AgentCall.worker)) == %@", worker)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            do {
                let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs], into: [PersistentContainer.shared.viewContext])
                }
            } catch {
                printAndLog(message: "Error batch deleting entity - AgentCall for worker: \(worker!): Error-> \(error.localizedDescription)", log: .coredata, logType: .error)
                fatalError(error.localizedDescription)
            }
            _ = calls.map {
                return AgentCall(context: context, agentCallEntryFromServer: $0, agent: worker!)
            }
            do {
                if context.hasChanges { try context.save() }
            } catch {
                printAndLog(message: "### \(#function) \(error.localizedDescription)", log: .coredata, logType: .error)
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func showAlert(withErrorMessage message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIAlertController.showTelaAlert(title: "Error", message: message, action: UIAlertAction(title: "OK", style: .cancel, handler: { action in
                completion?()
            }), controller: self, completion: {
                self.updateUI()
            })
        }
    }
}
